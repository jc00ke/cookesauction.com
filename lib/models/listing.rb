class Listing
    include DataMapper::Resource

    has 1, :page

    property :id,               Serial
    property :city,             String,     :required => true
    property :result,           String
    property :zip,              String,     :required => true
    property :sale_title,       String,     :required => true
    property :number_photos,    Integer,    :default => 0
    property :street_address,   String,     :required => true
    property :type,             Enum[:public_auction, :real_estate],
                                :default => :public_auction
    property :created_at,       DateTime
    property :updated_at,       DateTime
    property :starting_at,      DateTime
    property :update,           Text
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

end
