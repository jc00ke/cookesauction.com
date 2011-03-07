
module Page
  include DataMapper::Resource
  is :remixable
  property :id,                 Serial
  property :page_title,         String,     :required => true
  property :page_keywords,      Text
  property :page_description,   Text
  property :page_content,       Text
  property :page_visible,       Boolean,    :default => true
end
