class Page
  include Mongoid::Document
  embedded_in :listing
  field :title,         String,     :required => true
  field :keywords
  field :description
  field :content
  field :visible,       Boolean,    :default => true
end
