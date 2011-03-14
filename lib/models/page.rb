class Page
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :listing

  field :title
  field :keywords
  field :description
  field :content
  field :visible,
        :type => Boolean,
        :default => true

  validates_presence_of   :title, :description
end
