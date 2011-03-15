#!/usr/bin/env ruby

require "thor"
require "mini_magick"

class ProcessImages < Thor

  F = FileUtils::Verbose

  desc "process", "process the images in SOURCE & save them to DESTINATION"
  method_option :src,   :type => :string,   :required => true
  method_option :dest,  :type => :string,   :required => true
  def process
    src = options[:src]
    dest = options[:dest]
    unless File.exists?(src)
      say "#{src} doesn't exist", :red
      exit
    end
    Dir.chdir src
    F.mkdir dest unless File.exists?(dest)

    Dir.glob("*.{jpg,JPG}").each_with_index do |photo, idx|
      say "processing: #{photo} -> #{dest}/#{idx}.jpg", :green
      image = MiniMagick::Image.open(photo)
      image.quality 75
      
      # full size image
      image.scale "800x800"
      image.write "#{dest}/#{idx}.jpg"
      
      # small image
      image.thumbnail(200)
      image.write "#{dest}/#{idx}_small.jpg"
    end
  end
end

ProcessImages.start
