class Submission
    include DataMapper::Resource

    validates_length_of :comment, :max => 250

    property :id,         Serial
    property :name,       String,   :required => true
    property :email,      String,   :required => true, :format => :email_address
    property :comment,    Text,     :required => true
    property :created_at, DateTime

end
