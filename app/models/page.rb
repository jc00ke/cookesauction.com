class Page
  include DataMapper::Resource

  property :id,             Serial
  property :title,          String
  property :keywords,       Text
  property :description,    Text
  property :content,        Text
  property :visible,        Boolean
  property :url,            URI
end
