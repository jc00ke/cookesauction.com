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

    entries = Dir.glob("*.{jpg,JPG}").sort
    entries.each_with_index do |photo, idx|
      image = MiniMagick::Image.open(photo)
      image.quality 75
      
      # full size image
      image.scale "800x800"
      image.write "#{dest}/#{idx}.jpg"
      
      # small image
      image.size    "125x125"
      image.thumbnail    "125x125^"
      image.gravity "center"
      image.extent "125x125"
      image.write "#{dest}/#{idx}_small.jpg"
    end
    say "processed #{entries.size} photos"
  end
end

ProcessImages.start
