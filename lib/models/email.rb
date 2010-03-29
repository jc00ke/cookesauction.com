class Email
    include DataMapper::Resource

    validates_is_unique :email

    property :id,         Serial
    property :name,       String,   :required => true
    property :email,      String,   :required => true, :format => :email_address
    property :created_at, DateTime

end
