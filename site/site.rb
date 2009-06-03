require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'lib/partials'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'
require 'logger'
require 'rack-flash'

#TODO
# Get sales page looking nice so I can get this thing up on production
# Delayed Job for image resizing and email list
# Reverse PTR for slice
# Vlad
# nginx w/passenger


## MODELS ###########################

class Page
  include DataMapper::Resource
  
  belongs_to :listing
  
  property :id,         Serial
  property :title,      String, :nullable => false
  property :meta,       Text
  property :content,    Text
  property :visible,    Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime

end

class Listing
  include DataMapper::Resource
  
  has 1, :page
  
  property :id,             Serial
  property :city,           String,                               :nullable => false
  property :result,         String
  property :zip,            String,                               :nullable => false
  property :sale_title,     String,                               :nullable => false
  property :number_photos,  Integer,                              :default => 0
  property :street_address, String,                               :nullable => false
  property :type,           Enum[:public_auction, :real_estate],  :default => :public_auction
  property :content,        Text,                                 :nullable => false
  property :created_at,     DateTime
  property :updated_at,     DateTime
  property :starting_at,    DateTime
  property :visible,        Boolean,                              :default => false
  property :update,         Text
  property :state,          String,                               :nullable => false
  
  def nice_type
    self.type.to_s.split('_').each { |t| t.capitalize! }.join(' ')
  end

end

class Submission
  include DataMapper::Resource
  
  validates_length :comment, :max => 250
  
  property :id,         Serial
  property :name,       String, :nullable => false
  property :email,      String, :nullable => false, :format => :email_address
  property :comment,    Text,   :nullable => false
  property :created_at, DateTime
  
end

class Email
  include DataMapper::Resource
  
  validates_is_unique :email
  
  property :id,         Serial
  property :name,       String, :nullable => false
  property :email,      String, :nullable => false, :format => :email_address
  property :created_at, DateTime
  
end

class DataMapper::Validate::ValidationErrors
  def to_html
    output = "<ul>\n"
    self.each do |error|
      error.each do |e|
        output << "<li>#{e}</li>"
      end
    end
    output << "</ul>\n"
  end
end


## CONFIGURATION ###########################
set :sessions, true
use Rack::Flash, :accessorize => [:notice, :error]

configure :development do
  set :app_file, __FILE__
  set :reload, true
  DataMapper.setup(:default, "sqlite3:dev.db")
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper.auto_migrate!
end

configure :production do
  DataMapper.setup(:default, "sqlite3:prod.db")
end


## FILTERS ###########################
before do
  if request.path_info =~ /\/admin/ && request.path_info != '/admin/login'
    #redirect '/admin/login' unless session[:admin]
  end
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
    flash[:notice] = 'Thanks for signing up! You\'ll hear from us next time we post a sale.'
    haml :signup
  else
    #Don't like this.
    haml :error
  end
end

## UNSUBSCRIBE ###########################
get '/unsubscribe' do
  @title, @body_id = prep 'unsubscribe'
  haml :unsubscribe
end

post '/unsubscribe' do
  @title, @body_id = prep 'unsubscribe'
  haml :bye
end

## HIRE US ###########################
get '/hire-us' do
  @title, @body_id = prep 'hire-us'
  haml 'hire-us'.to_sym
end

post '/hire-us' do
  halt 500, 'Get out ye bot!' unless params[:email].empty?
  
  s = Submission.new
  s.name = params[:name]
  s.email = params[:your_email]
  s.comment = params[:message]
  
  @title, @body_id = prep 'hire-us'
  if s.save
    flash.now[:notice] = 'Thanks for signing up! You\'ll hear from us next time we post a sale.'
  else
    flash.now[:error] = "Something didn\'t go right. Can you try again?#{s.errors.to_html}"
    @name = params[:name]
    @email = params[:your_email]
    @message = params[:message]
  end
  haml 'hire-us'.to_sym
end

## SALE ###########################
get '/sale/:id' do
  @listing = Listing.get(params[:id])
  not_found unless @listing
  haml :listing
end


## ADMIN ###########################
get '/admin' do
  haml :admin_index
end

get '/admin/login' do
  haml :admin_login
end

post '/admin/login' do
  if params[:password] == 'asdfzxcv'
    session[:admin] = true
    redirect '/admin'
  end
  halt 401, 'Get outa here!'
end

get '/admin/testimonials' do
  
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
