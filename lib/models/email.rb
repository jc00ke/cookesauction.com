class Email
    include DataMapper::Resource

    validates_uniqueness_of :email

    property :id,         Serial
    property :name,       String,   :required => true
    property :email,      String,   :required => true, :format => :email_address
    property :created_at, DateTime

end
