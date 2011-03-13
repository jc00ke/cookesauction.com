
module Page
  include DataMapper::Resource
  is :remixable
  property :id,                 Serial
  property :title,         String,     :required => true
  property :keywords,      Text
  property :description,   Text
  property :content,       Text
  property :visible,       Boolean,    :default => true
end
