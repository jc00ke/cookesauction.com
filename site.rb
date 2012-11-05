require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'sass'
require 'girl_friday'
$LOAD_PATH.unshift File.expand_path('lib')
require 'partials'
require 'models'
require 'logger'
require 'pony'

# MongoDB configuration
Mongoid.configure do |config|
  if ENV['MONGOLAB_URI']
    conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
    uri = URI.parse(ENV['MONGOLAB_URI'])
    config.master = conn.db(uri.path.gsub(/^\//, ''))
  else
    config.master = Mongo::Connection.from_uri("mongodb://localhost:27017").db('cookesauction')
  end
end

enable :sessions

## CONFIGURATION ###########################
configure do
  set :email_regexp,  EMAIL_REGEXP
  set :haml,          { :format => :html5 }
  set :markdown,  :layout_engine => :haml
end

configure :development do
  require 'ap'
  Sinatra::Application.reset!
  use Rack::Reloader
  set :password,  'asdfzxcv'

  set :cdn,          ""
  set :image_prefix, "/images/sales"
  set :send_to,       "jesse@jc00ke.com"
  set :smtp,          { :address => "localhost",
                        :port     => 25,
                        :authentication   => :plain,
                        :user_name        => 'foo',
                        :password         => 'bar',
                        :domain           => 'baz'
                      }
end

configure :production do
  set :password,      ENV["ADMIN_PASSWORD"]
  set :cdn,           "http://assets.cookesauction.com"
  set :image_prefix,  "#{settings.cdn}/images/sales"
  set :send_to,       "jesse@cookesauction.com"
  set :smtp,          Email.smtp
end


## FILTERS ###########################
before do
  prep

  if request.path_info =~ /\/admin/ && request.path_info != '/admin/login'
    @action = request.path_info
    redirect '/admin/login' unless session[:admin]
  end

  # catch bots in the honeypot
  if request.post? && params[:email]
    halt 500, 'Get out ye bot!' unless params[:email].empty?
  end
end


## HELPERS ###########################
helpers do
  include Sinatra::Partials

  def image_tag(listing_slug, idx)
    %Q|
      <a href="#{settings.image_prefix}/#{listing_slug}/#{idx}.jpg" rel="photos">
        <img src="#{settings.image_prefix}/#{listing_slug}/#{idx}_small.jpg" alt="listing image #{idx}" />
      </a>
    |
  end

  def escaped_address(l)
    l.map_location.gsub(/, /, ',').gsub(/ /, "+")
  end

  def prep
    page = request.path_info.sub('/','').gsub(/\//,'_')
    @title = page.gsub(/[-|_]/, ' ').capitalize
    @body_id = page.gsub(/-/, '_')
    if page == ''
      @title = 'Welcome!'
      @body_id = 'home'
    end
    @is_admin = !session[:admin].nil?
  end

  def display(view)
    layout = (view.to_s.match(/admin/)) ? :layout_admin : :layout
    haml view, { :layout => layout }
  end

  def display_errors(model)
    errors = model.errors.full_messages.inject([]) { |memo, m| memo << m }.join("</li><li>")
    "<ul><li>#{errors}</li></ul>"
  end

  def valid_email_params?(params)
    present = [:name, :your_email, :message].all?{ |p| params[p].length > 0 }
    email_format = params[:your_email].to_s =~ settings.email_regexp

    present && email_format
  end

  def email_body(params)
    %Q|
      Name: #{params[:name]}

      Message
      ------------------------
      #{params[:message]}
    |
  end

  def send_email(params)
    if settings.production?
      Pony.mail(  :to => settings.send_to,
                  :from         => params[:your_email],
                  :subject      => "Message from Cooke's",
                  :body         => email_body(params),
                  :via          => :smtp,
                  :via_options  => settings.smtp
               )
    else
      puts email_body(params)
    end
  end

  def listing_link_href(listing)
    "/sale/#{listing.slug}"
  end

end


## HOME PAGE ###########################
get '/' do
  listings   = Listing.upcoming
  @next_listing = listings.first
  @listings = listings.from(1)
  display :index
end

## HOME PAGE ###########################
get '/past-sales' do
  @listings   = Listing.past
  display :"past-sales"
end

## STYLES ###########################
get '/master.css' do
  content_type 'text/css', :charset => 'utf-8'
  expires 600, :public, :must_revalidate
  sass :master
end

## CONTACT US ###########################
post '/contact-us' do
  @title = "Contact Us"
  if valid_email_params?(params)
    begin
      send_email(params)
      flash.now[:notice] = "Your email was successfully sent."
    rescue Exception => e
      status 500
      flash.now[:error] = "An error occured when trying to send the email. Please try again:\n\n#{e.message}"
      @name, @email, @message = params[:name], params[:your_email], params[:message]
    end
  else
    status 400
    flash.now[:error] = "Please double check your entries"
    @name, @email, @message = params[:name], params[:your_email], params[:message]
  end
  display :"contact-us"
end

## SUBSCRIBE ###########################
get '/signup' do
  display :signup
end

post '/signup' do
  if valid_email_params?(params.merge(:message => 'asdf'))
    email = Email.new( :name => params[:name], :email => params[:your_email])

    if email.save
      flash.now[:notice] = "Thanks for signing up! You'll hear from us next time we post a sale."
    else
      flash.now[:error] = "Your information could not be saved. Please try again. #{display_errors(email)}"
      @name, @email = params[:name], params[:your_email]
    end
  else
    status 400
    flash.now[:error] = "Please double check your entries"
    @name, @email = params[:name], params[:your_email]
  end
  display :signup
end

## UNSUBSCRIBE ###########################
get '/unsubscribe/:id' do
  begin
    email = Email.find(params[:id])
    email.destroy
    flash.now[:notice] = "Bye! We hope you come back soon!"
  rescue Mongoid::Errors::DocumentNotFound
    flash.now[:error] = "Your email could not be found. Try the form below or <a href='/contact-us'>contact us</a> directly."
    @email = params[:your_email]
  end
  @title = "Bye!"
  display :unsubscribe
end

get '/unsubscribe' do
  display :unsubscribe
end

post '/unsubscribe' do
  email = Email.first(:conditions => { :email => params[:your_email] })
  if email
    email.destroy
    flash.now[:notice] = "Bye! We hope you come back soon!"
  elsif
    flash.now[:error] = "#{params[:your_email]} could not be found. Please try again."
    @email = params[:your_email]
  end
  display :unsubscribe
end

## HIRE US ###########################
get '/hire-us' do
    redirect to('/contact-us')
end

## SALE ###########################

# /sale/2010-9-28-0/some-sale-on-my-bday
get "/sale/:year-:month-:day-:previous_id" do |year, month, day, previous_id|
  @listing = Listing.find_by_slug(year, month, day, previous_id)
  not_found unless @listing
  display :listing
end

get '/sale/:id' do
  @listing = Listing.first( :conditions => { :id => params[:id] })
  not_found unless @listing
  display :listing
end

get "/sale" do
  @id = params[:previous_id]
  markdown :previous_sale
end

## PRIVACY ###########################
get '/privacy' do
  markdown :privacy
end


## ADMIN ###########################
get '/admin' do
  @listings = Listing.desc(:starting_at)
  display :admin_index
end

get '/admin/login' do
  session[:admin] = nil
  display :admin_login
end

post '/admin/login' do
  if params[:password] == options.password
    session[:admin] = true
    redirect '/admin'
  end
  flash[:error] = "Sorry, that wasn't the right password."
  redirect '/admin/login'
end

get '/admin/listings/new' do
  @listing = Listing.new
  @listing.build_page
  display :admin_listing_edit
end

post '/admin/listings/new' do
  @listing = Listing.new
  @listing.build_page
  @listing.page.title = params[:page_title]
  @listing.page.keywords = params[:page_keywords]
  @listing.page.description = params[:page_description]
  @listing.page.visible = !!params[:page_visible]
  @listing.page.content = params[:page_content]

  if params[:latitude] && params[:longitude]
    @listing.location = [params[:latitude], params[:longitude]]
  end

  @listing.sale_title = params[:sale_title]
  @listing.starting_at = params[:starting_at]
  @listing.street_address = params[:street_address]
  @listing.city = params[:city]
  @listing.state = params[:state].upcase
  @listing.zip = params[:zip]
  @listing.number_photos = params[:number_photos]
  @listing.sale_type = params[:sale_type].intern
  if @listing.save
    flash.now[:notice] = "Sale saved"
    redirect '/admin'
  else
    flash.now[:error] = display_errors(@listing)
    display :admin_listing_edit
  end
end

get '/admin/listings/:id' do
  @listing = Listing.first(:conditions => { :id => params[:id] })
  unless @listing
    flash.now[:warning] = "Cannot find sale listing with id #{params[:id]}"
    redirect "/admin"
  end
  display :admin_listing_edit
end

post '/admin/listings/:id' do
  @listing = Listing.first(:conditions => { :id => params[:id] })
  @listing.page.title = params[:page_title]
  @listing.page.keywords = params[:page_keywords]
  @listing.page.description = params[:page_description]
  @listing.page.visible = !!params[:page_visible]
  @listing.page.content = params[:page_content]

  if params[:latitude] && params[:longitude]
    @listing.location = [params[:latitude], params[:longitude]]
  end

  @listing.sale_title = params[:sale_title]
  @listing.starting_at = params[:starting_at]
  @listing.street_address = params[:street_address]
  @listing.city = params[:city]
  @listing.state = params[:state].upcase
  @listing.zip = params[:zip]
  @listing.number_photos = params[:number_photos]
  @listing.sale_type = params[:sale_type].intern
  if @listing.save
    flash.now[:notice] = "Sale saved."
    redirect '/admin'
  else
    flash.now[:error] = display_errors(@listing)
    display :admin_listing_edit
  end
end

get '/admin/send_listings' do
  Email.queue
  redirect '/admin'
end

get "/Sale.cfm" do
  listing = Listing.first(:conditions => { :previous_id => params[:qSale] })
  redirect to("/sale/#{listing.slug}"), 301
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
  @title = "Oops, it's not here!"
  @body_id = 'not_found'
  display :not_found
end

error do
  @title = 'Hmm, something broke...'
  @body_id = 'error'
  display :error
end
