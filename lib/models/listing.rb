class Listing
    include Mongoid::Document
    embeds_one :page

    field :city,                         :required => true
    field :result,                 
    field :zip,                          :required => true
    field :sale_title,                   :required => true
    field :number_photos,    Integer,    :default => 0
    field :street_address,               :required => true
    field :sale_type,        Enum[:public_auction, :real_estate],
                             :default => :public_auction
    field :created_at,       DateTime
    field :updated_at,       DateTime
    field :starting_at,      DateTime
    field :update_text,          
    field :state,                        :required => true

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
      all({ :starting_at.gt => Time.now, :page => { :visible => true } })
    end
     
    def self.past
      all(:visible => true, :starting_at.lt => Time.now)
    end
end
