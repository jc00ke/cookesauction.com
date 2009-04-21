require 'rubygems'
require 'sinatra'
require 'lib/partials'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'
require 'logger'


## MODELS ###########################
class Listing
  include DataMapper::Resource
  
  property :id, Serial
  property :city, String, :nullable => false
  property :result, String
  property :zip, String, :nullable => false
  property :title, String, :nullable => false
  property :number_photos, Integer, :default => 0
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
  
  validates_length :comment, :max => 250
  
  property :id, Serial
  property :name, String, :nullable => false
  property :email, String, :format => :email_address, :nullable => false
  property :comment, Text, :nullable => false
  
end

class Email
  include DataMapper::Resource
  
  validates_is_unique :email
  
  property :id, Serial
  property :name, String, :nullable => false
  property :email, String, :format => :email_address, :nullable => false
  
end

## CONFIGURATION ###########################
configure :development do
  DataMapper.setup(:default, "sqlite3:dev.db")
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper.setup(:default, "sqlite3:prod.db")
end


## HELPERS ###########################
helpers do
  include Sinatra::Partials

  def prep(page)
    return page.gsub(/-/, ' ').capitalize, page.gsub(/-/, '_')
  end

end


## HOME PAGE ###########################
get '/' do
  @title = 'Welcome!'
  @body_id = 'home'
	haml :index
end

## STYLES ###########################
get '/master.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :master  
end

## SUBSCRIBE ###########################
get '/signup' do
  @title, @body_id = prep 'signup'
  haml :signup, :layout => !request.xhr?
end

post '/signup' do
  halt 500, 'Get out ye bot!' if params[:email]
  
  email = Email.new
  email.name = params[:name]
  email.email = params[:your_email]
  
  @title, @body_id = prep 'signup'
  if email.save
    haml :thanks, :layout => !request.xhr?
  else
    #Don't like this.
    haml :error, :layout => !request.xhr?
  end
end

## UNSUBSCRIBE ###########################
get '/unsubscribe' do
  @title, @body_id = prep 'unsubscribe'
  haml :unsubscribe, :layout => !request.xhr?
end

post '/unsubscribe' do
  @title, @body_id = prep 'unsubscribe'
  haml :bye, :layout => !request.xhr?
end


## NORMAL PAGES ###########################
get '/:page' do
  begin
    @title, @body_id = prep params[:page]
    haml params[:page].intern
  rescue Errno::ENOENT # haml can't find the view, which means the page isn't there. Throw a 404
    not_found
  rescue Exception => e
    error
  end
end

## ERROR PAGES ###########################
not_found do
  @title = 'Oops, it\'s not here!'
  @body_id = 'not_found'
  haml :not_found
end

error do
  @title = 'Hmm, something broke...'
  @body_id = 'error'
  haml :error
end

get '/admin/testimonials' do
  
end
