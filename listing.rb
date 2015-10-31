require "time"
require "json"
require "tzinfo"
require "kramdown"

class Listing
  PROPERTIES = %w(slug street_address city state zip location number_photos starting_at type title content visible result update_text).freeze
  PROPERTIES.each do |property|
    attr_reader property.intern
  end

  class << self
    def upcoming
      now = Time.now
      all.
        select { |listing| Time.parse(listing.starting_at) > now }.
        sort_by { |listing| Time.parse(listing.starting_at) }
    end

    def all
      file = File.read("data/listings.json")
      JSON.parse(file).map { |hsh| new(hsh) }
    end
  end

  def initialize(hsh)
    PROPERTIES.each do |property|
      instance_variable_set("@#{property}", hsh.fetch(property))
    end
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
end
