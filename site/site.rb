%w[rubygems sinatra lib/partials dm-core dm-validations dm-timestamps dm-types logger].each { |r| require r }

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

class Submission
  include DataMapper::Resource
  
  property :id, Serial
  property :email, String, :format => :email_address, :nullable => false
  property :comment, Text, :length => (1..250), :nullable => false
  
  
end

## HELPERS
helpers do

  def prep(page)
    return page.gsub(/-/, ' ').capitalize, page.gsub(/-/, '_')
  end

end


## HOME PAGE
get '/' do
  @title = 'Welcome!'
  @body_id = 'home'
	haml :index
end

## STYLES
get '/master.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :master  
end

get '/signup' do
  @title, @body_id = prep 'signup'
  haml :signup, :layout => !request.xhr?
end

post '/signup' do
  @title, @body_id = prep 'signup'
  haml :thanks, :layout => !request.xhr?
end


## NORMAL PAGES
get '/:page' do
  begin
    @title, @body_id = prep params[:page]
    haml params[:page].intern
  rescue Errno::ENOENT # haml can't find the view, which means the page isn't there. Throw a 404
    not_found
  rescue
    error
  end
end

## ERROR PAGES
not_found do
  @title = 'Oops, it\'s not here!'
  @body_id = 'not_found'
  haml :not_found
end

error do
  @title = 'Hmm, something broke...'
  @body_id = 'error'
  haml :not_acceptable
end
