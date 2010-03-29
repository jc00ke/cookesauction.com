class Page
    include DataMapper::Resource

    belongs_to :listing

    property :id,           Serial
    property :title,        String,     :required => true
    property :keywords,     Text
    property :description,  Text
    property :content,      Text
    property :visible,      Boolean,    :default => true

end
