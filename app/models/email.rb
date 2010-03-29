class Email
    include DataMapper::Resource

    property :id,     Serial
    property :name,   String,   :required   => true
    property :email,  String,   :required   => true,
                                :format     => :email_address
    validates_is_unique :email
end
