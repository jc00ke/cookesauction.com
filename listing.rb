require "time"
require "yaml"
require "tzinfo"
require "kramdown"

class Listing
  PROPERTIES = %w(slug street_address city state zip location number_photos starting_at type title content visible result update_text).freeze
  PROPERTIES.each do |property|
    attr_reader property.intern
  end
  attr_reader :hide_photos
  attr_reader :inline_image_list
  attr_reader :card_photo

  class << self
    def upcoming
      now = Time.now
      visible.
        select { |listing| Time.parse(listing.starting_at) > now }.
        sort_by { |listing| Time.parse(listing.starting_at) }
    end

    def all
      YAML.load_file("data/listings.yml").map { |hsh| new(hsh) }
    end

    def visible
      all.select(&:visible)
    end

    def search_data
      visible.each_with_object(Hash.new) { |listing, hsh|
        hsh[listing.id] = listing.search_data
      }.to_json
    end

    def previous
      now = Time.now
      visible.
        select { |listing| Time.parse(listing.starting_at) < now }
    end
  end

  def initialize(hsh)
    PROPERTIES.each do |property|
      instance_variable_set("@#{property}", hsh.fetch(property))
    end
    @hide_photos = !!hsh["hide_photos"]
    @inline_image_list = hsh.fetch("inline_image_list", [])
    @card_photo = hsh.fetch("custom_card_photo", 0)
    @start_time = Time.parse(self.starting_at)
  end

  def id
    self.slug
  end

  def public_auction?
    type == :public_auction
  end

  def real_estate?
    type == :real_estate
  end

  def nice_type
    type.to_s.split('_').each { |t| t.capitalize! }.join(' ')
  end

  def starting
    @start_time.strftime("%B %d, %Y %I:%M %p")
  end

  def has_photos?
    number_photos.to_i > 0
  end

  def photosish
    has_photos? ? (0...number_photos).to_a : []
  end

  def show_photos?
    !@hide_photos
  end

  def map_location
    if location
      location.all?(&:present?) ? location.join(',') : full_address
    end
  end

  def latitude
    location.first if location
  end

  def longitude
    location.last if location
  end

  def full_address
    "#{street_address}, #{city}, #{state} #{zip}"
  end

  def content_html
    @content_html ||= Kramdown::Document.new(content).to_html
  end

  def page_title
    "#{nice_type} on #{starting} in #{city}, #{state}"
  end

  def search_data
    {
      :id               => id,
      :title            => title,
      :content          => content.gsub("###", " ").gsub("\n", " ").gsub("\r", " "),
      :city             => city,
      :starting         => starting,
      :numbered_lots    => inline_image_list.map { |item| item["description"] }.join(" ")
    }
  end
end
