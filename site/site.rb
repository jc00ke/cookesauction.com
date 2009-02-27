%w[rubygems sinatra dm-core dm-validations dm-timestamps dm-types logger].each { |r| require r }

## CONFIGURATION
configure :development do
  DataMapper.setup(:default, "sqlite3:dev.db") && DataMapper.auto_migrate!
  DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do
  DataMapper.setup(:default, "sqlite3:prod.db")
end


## MODELS
class Listing
  include DataMapper::Resource
  
  property :id, Serial

  property :city, String, :nullable => false
  property :result, String
  property :zip, String, :nullable => false
  property :title, String, :nullable => false
  property :number_photos, Integer, :default => 0
  property :id, Serial
  property :street_address, String, :nullable => false
  property :type, Enum[:public_auction, :real_estate], :default => :public_auction
  property :content, Text, :nullable => false
  property :created_at, DateTime
  property :updated_at, DateTime
  property :starting_at, DateTime
  property :visible, Boolean, :default => false
  property :update, Text
  property :state, String, :nullable => false

end



## HOME PAGE
get '/' do
	haml :index
end

## STYLES
get '/master.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :master  
end




## NORMAL PAGES
get '/:page' do
  begin
    haml params[:page].intern
  rescue
    not_found
  end
end

## ERROR PAGES
not_found do
  haml :not_found
end

error do
  haml :not_acceptable
end
