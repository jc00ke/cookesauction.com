class Email
  include DataMapper::Resource

  # property <name>, <type>
  property :id,     Serial
  property :name,   String, :required   => true
  property :email,  String, :required   => true,
                            :format     => :email_address
end
