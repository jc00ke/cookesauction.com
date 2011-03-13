class Listing
    include DataMapper::Resource
    remix 1, :page, :as => "page"

    property :id,               Serial
    property :city,             String,     :required => true
    property :result,           String
    property :zip,              String,     :required => true
    property :sale_title,       String,     :required => true
    property :number_photos,    Integer,    :default => 0
    property :street_address,   String,     :required => true
    property :sale_type,        Enum[:public_auction, :real_estate],
                                :default => :public_auction
    property :created_at,       DateTime
    property :updated_at,       DateTime
    property :starting_at,      DateTime
    property :update_text,      Text
    property :state,            String,     :required => true

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
