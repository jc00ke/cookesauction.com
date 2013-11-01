#!/usr/bin/env ruby

require "thor"
require "mini_magick"
require "fog"

class Images < Thor

  F = FileUtils::Verbose

  no_tasks do
    def check_dir(src)
      unless File.exists?(src)
        say "#{src} doesn't exist", :red
        exit
      end
    end
  end

  desc "process", "process the images in SOURCE & save them to DESTINATION. [start]"
  method_option :src,   :type => :string,   :required => true
  method_option :dest,  :type => :string,   :required => true
  method_option :start,  :type => :numeric
  def process
    src = options[:src]
    dest = options[:dest]
    start = options[:start] || 0
    check_dir(src)
    Dir.chdir src
    F.mkdir dest unless File.exists?(dest)

    entries = Dir.glob("*.{jpg,JPG}").sort
    entries.each_with_index do |photo, idx|
      image = MiniMagick::Image.open(photo)
      image.quality 75

      i = idx + start

      # full size image
      image.scale "800x800"
      image.write "#{dest}/#{i}.jpg"

      # small image
      image.size    "125x125"
      image.thumbnail    "125x125^"
      image.gravity "center"
      image.extent "125x125"
      image.write "#{dest}/#{i}_small.jpg"
    end
    say "processed #{entries.size} photos"
  end

  desc "upload", "upload images from SOURCE to DEST"
  method_option :src,  :type => :string, :required => true
  method_option :dest, :type => :string, :required => true
  def upload
    Fog::Logger[:warning] = nil
    dest = options[:dest]
    src = options[:src]
    check_dir(src)

    connection = Fog::Storage.new({
      :provider => 'AWS',
      :aws_access_key_id => ENV['S3_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['S3_SECRET_ACCESS_KEY'],
      :region => 'us-east-1'
    })

    directory = connection.directories.create(
      :key => "cookes-auction-service/images/sales/#{dest}",
      :public => true
    )
    Dir.chdir src
    Dir.glob("*.jpg").sort.each do |image|
      directory.files.create({
        :key => image,
        :body => File.open(image),
        :public => true
      })
    end
    Fog::Logger[:warning] = STDOUT
  end
end

Images.start
