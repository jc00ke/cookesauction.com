#!/usr/bin/env ruby

require "thor"
require "mini_magick"

class ProcessImages < Thor

  F = FileUtils::Verbose

  desc "process", "process the images in SOURCE & save them to DESTINATION"
  method_option :src,   :type => :string,   :required => true
  method_option :dest,  :type => :string,   :required => true
  method_option :start,  :type => :numeric
  def process
    src = options[:src]
    dest = options[:dest]
    start = options[:start] || 0
    unless File.exists?(src)
      say "#{src} doesn't exist", :red
      exit
    end
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
end

ProcessImages.start
