class Listing
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_one :page

  field :sale_title
  field :street_address
  field :city
  field :state
  field :zip
  field :result                 
  field :number_photos,
        :type => Integer,
        :default => 0
  field :sale_type,
        :type => Symbol,
        :default => :public_auction
  field :starting_at,
        :type => DateTime
  field :update_text    
  field :previous_id,
        :type => Integer
  field :slug

  validates_presence_of :sale_title, :street_address,
                        :city, :state, :zip
  validates_inclusion_of :sale_type, :in => [:public_auction, :real_estate]
  validates_uniqueness_of :slug

  before_create :gen_slug

  def nice_type
    sale_type.to_s.split('_').each { |t| t.capitalize! }.join(' ')
  end

  def starting
    starting_at.strftime("%B %d, %Y %I:%M %p")
  end

  def dtstart
    starting_at.strftime("%Y-%m-%dT%H:%M-06:0000")
  end

  def has_photos?
    number_photos > 0
  end

  def photosish
    has_photos? ? (0...number_photos).to_a : []
  end

  def full_address
    "#{street_address}, #{city}, #{state} #{zip}"   
  end

  def self.upcoming
    where(:starting_at.gt => Time.now, "page.visible" => true).asc(:starting_at)
  end
   
  def self.past
    where(:starting_at.lt => Time.now, "page.visible" => true).asc(:starting_at)
  end

  def gen_slug
    self.slug = Listing.slug_format(starting_at.year, starting_at.month, starting_at.day, previous_id)
  end

  def self.slug_format(year, month, day, p_id)
    "#{year}-#{month}-#{day}-#{p_id || rand(100) + 200}"
  end

  def self.find_by_slug(year, month, day, previous_id)
    first :conditions => { :slug => Listing.slug_format(year, month, day, previous_id) }
  end
end
