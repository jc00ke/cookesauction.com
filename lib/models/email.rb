class Email
    include Mongoid::Document
    include Mongoid::Timestamps

    validates_uniqueness_of :email

    field :name,                 :required => true
    field :email,                :required => true, :format => :email_address
end
