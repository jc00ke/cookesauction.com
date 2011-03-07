require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'lib/partials'
require 'lib/models'
require 'logger'
require 'rack-flash'
require 'pony'



## CONFIGURATION ###########################
configure do
  set :sessions, true
  use Rack::Flash, :accessorize => [:notice, :error]
  set :email_regexp,  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  set :haml,          { :format => :html5 }

end

configure :development do
  require 'pp'
  #Sinatra::Application.reset!
  use Rack::Reloader
  DataMapper.setup(:default, "sqlite3:dev.db")
  DataMapper::Logger.new(STDOUT, :debug)
  DataMapper.auto_upgrade!
  set :password,  'asdfzxcv'

  set :image_prefix, "/images"
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
  DataMapper.setup(:default, "sqlite3:prod.db")
  set :image_prefix, "http://assets.cookesauction.com/sales"
  set :send_to,       "jesse@cookesauction.com"
  set :smtp,          { :address => "smtp.sendgrid.net",
                        :port     => 25,
                        :authentication   => :plain,
                        :user_name        => ENV['SENDGRID_USERNAME'],
                        :password         => ENV['SENDGRID_PASSWORD'],
                        :domain           => ENV['SENDGRID_DOMAIN']
                      }
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

end


## HOME PAGE ###########################
get '/' do
    @listings   = Listing.all(:starting_at.gt => Time.now)
    display :index
end

## HOME PAGE ###########################
get '/past-sales' do
    @listings   = Listing.all
    display :"past-sales"
end

## STYLES ###########################
get '/master.css' do
    content_type 'text/css', :charset => 'utf-8'
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
    email = Email.new
    email.name = params[:name]
    email.email = params[:your_email]

    if email.save
        flash.now[:notice] = 'Thanks for signing up! You\'ll hear from us next time we post a sale.'
    else
        flash.now[:error] = "Your information could not be saved. Please try again. #{email.errors.to_html}"
        @name, @email = params[:name], params[:your_email]
    end
    display :signup
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
        flash.now[:error] = "#{params[:your_email]} could not be found. Please try again."
        @email = params[:your_email]
    end
    display :unsubscribe
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

    if s.save && send_email(params.merge(:message => "Hire Us: #{params[:message]}"))
        flash.now[:notice] = "Thanks for contacting us! We will get back to you shortly."
    else
        flash.now[:error] = "Something didn't go right. Can you try again?#{s.errors.to_html}"
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
    if params[:password] == options.password
        session[:admin] = true
        redirect '/admin'
    end
    flash.now[:error] = "Sorry, that wasn't the right password."
    redirect '/admin/login'
end

get '/admin/listings/new' do
    @listing = Listing.new
    @page = Page.new
    display :admin_listing_edit
end

post '/admin/listings/new' do
    @listing = Listing.new
    @listing.page_title = params[:page_title]
    @listing.page_keywords = params[:page_keywords]
    @listing.page_description = params[:page_description]
    @listing.page_visible = params[:page_visible]
    @listing.page_content = params[:page_content]

    @listing.sale_title = params[:sale_title]
    @listing.starting_at = params[:starting_at]
    @listing.street_address = params[:street_address]
    @listing.city = params[:city]
    @listing.state = params[:state].upcase
    @listing.zip = params[:zip]
    @listing.number_photos = params[:number_photos]
    @listing.sale_type = params[:sale_type].intern
    if @listing.save
        flash.now[:message] = "Sale saved."
        redirect '/admin'
    else
      flash.now[:error] = listing.errors.to_html
      display :admin_listing_edit
    end
end

get '/admin/listings/:id' do
    @listing = nil
    begin
        @listing = Listing.first(params[:id].to_i)
    rescue
        flash.now[:error] = "Something wrong with the id param."
    end
    unless @listing
        flash.now[:warning] = "Cannot find sale listing with id #{params[:id]}"
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
    @title = "Oops, it's not here!"
    @body_id = 'not_found'
    display :not_found
end

error do
    @title = 'Hmm, something broke...'
    @body_id = 'error'
    display :error
end
