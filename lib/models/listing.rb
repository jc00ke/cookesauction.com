class Listing
    include Mongoid::Document
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
    field :created_at,
          :type => DateTime
    field :updated_at,
          :type => DateTime
    field :starting_at,
          :type => DateTime
    field :update_text          

    validates_presence_of :sale_title, :street_address,
                          :city, :state, :zip
    validates_inclusion_of :sale_type, :in => [:public_auction, :real_estate]

    def nice_type
        self.type.to_s.split('_').each { |t| t.capitalize! }.join(' ')
    end

    def starting
        starting_at.strftime("%B %d, %Y %I:%M %p")
    end

    def dtstart
        starting_at.strftime("%Y-%m-%dT%H:%M-06:0000")
    end
     
    def self.upcoming
      where(:starting_at.gt => Time.now, "page.visible" => true)
    end
     
    def self.past
      where(:starting_at.lt => Time.now, "page.visible" => true)
    end
end
