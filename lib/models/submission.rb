class Submission
    include Mongoid::Document

    validates_length_of :comment, :max => 250

    property :name,         :required => true
    property :email,        :required => true, :format => :email_address
    property :comment,      :required => true
    property :created_at,   DateTime

end
