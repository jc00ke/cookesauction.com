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
  
  property :id,         						Serial
  property :title,      						String, :nullable => false
  property :keywords,								Text
  property :description,						Text
  property :content,								Text
  property :visible,    						Boolean, :default => true

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
  property :created_at,     DateTime
  property :updated_at,     DateTime
  property :starting_at,    DateTime
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
  prep

  if request.path_info =~ /\/admin/ && request.path_info != '/admin/login'
		@action = request.path_info
    redirect '/admin/login' unless session[:admin]
  end

  if request.post? && params[:email]
    halt 500, 'Get out ye bot!' unless params[:email].empty?
  end
end


## HELPERS ###########################
helpers do
  include Sinatra::Partials

  def prep
    page = request.path_info.sub('/','').gsub(/\//,'_')
    @title = page.gsub(/[-|_]/, ' ').capitalize
    @body_id = page.gsub(/-/, '_')
    if page == ''
      @title = 'Welcome!' 
      @body_d = 'home'
    end
    @is_admin = !session[:admin].nil?
  end

  def display(view)
   layout = (view.to_s.match(/admin/)) ? :layout_admin : :layout
   haml view, { :layout => layout }
  end

end


## HOME PAGE ###########################
get '/' do
	display :index
end

## STYLES ###########################
get '/master.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :master  
end

## SUBSCRIBE ###########################
get '/signup' do
  display :signup
end

post '/signup' do
  email = Email.new
  email.name = params[:name]
  email.email = params[:your_email]
  
  if email.save
    flash[:notice] = 'Thanks for signing up! You\'ll hear from us next time we post a sale.'
    display :signup
  else
    flash[:error] = "Your information could not be saved. Please try again."
    redirect '/signup'
  end
end

## UNSUBSCRIBE ###########################
get '/unsubscribe' do
  display :unsubscribe
end

post '/unsubscribe' do
  email = Email.first(:email => params[:your_email])
  if email
    email.destroy
    display :bye
  elsif
    flash[:error] = "#{params[:your_email]} could not be found. Please try again."
    redirect '/unsubscribe'
  end
end

## HIRE US ###########################
get '/hire-us' do
  display 'hire-us'.to_sym
end

post '/hire-us' do
  
  s = Submission.new
  s.name = params[:name]
  s.email = params[:your_email]
  s.comment = params[:message]
  
  if s.save
    flash.now[:notice] = 'Thanks for signing up! You\'ll hear from us next time we post a sale.'
  else
    flash.now[:error] = "Something didn\'t go right. Can you try again?#{s.errors.to_html}"
    @name = params[:name]
    @email = params[:your_email]
    @message = params[:message]
  end
  display 'hire-us'.to_sym
end

## SALE ###########################
get '/sale/:id' do
  @listing = Listing.get(params[:id])
  not_found unless @listing
  display :listing
end


## ADMIN ###########################
get '/admin' do
  @listings = Listing.all(:order => [:starting_at.desc])
  display :admin_index
end

get '/admin/login' do
  session[:admin] = nil
  display :admin_login
end

post '/admin/login' do
  if params[:password] == 'asdfzxcv'
    session[:admin] = true
    redirect '/admin'
  end
  flash[:error] = 'Sorry, that wasn\'t the right password.'
  redirect '/admin/login'          
end

get '/admin/listings/new' do
  @listing = Listing.new
  @page = Page.new
  display :admin_listing_edit
end

post '/admin/listings/new' do
  listing = Listing.new
  page = Page.new
	page.title = params[:page_title]
	page.keywords = params[:page_keywords]
	page.description = params[:page_description]
	page.visible = params[:page_visible]
	page.content = params[:page_content]
	listing.page = page

	listing.sale_title = params[:sale_title]
	listing.starting_at = params[:starting_at]
	listing.street_address = params[:street_address]
	listing.city = params[:city]
	listing.state = params[:state].upcase
	listing.zip = params[:zip]
	listing.number_photos = params[:number_photos]
	listing.type = params[:type]
	if listing.save
		flash[:message] = "Sale saved."
		redirect '/admin'
	else
		flash[:error] = listing.errors.to_html
		display :admin_listing_edit
	end
end

get '/admin/listings/:id' do
  @listing = nil
	begin
		@listing = Listing.first(params[:id].to_i)
	rescue
		flash[:error] = "Something wrong with the id param."
	end
  unless @listing
    flash[:warning] = "Cannot find sale listing with id #{params[:id]}"
  end
  display :admin_listing_edit
end


## NORMAL PAGES ###########################
get '/:page' do
  begin
    display params[:page].intern
  rescue Errno::ENOENT # display can't find the view, which means the page isn't there. Throw a 404
    not_found
  rescue Exception => e
    error
  end
end

## ERROR PAGES ###########################
not_found do
  @title = 'Oops, it\'s not here!'
  @body_id = 'not_found'
  display :not_found
end

error do
  @title = 'Hmm, something broke...'
  @body_id = 'error'
  display :error
end
