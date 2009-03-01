require 'rubygems'
$:.unshift File.dirname(__FILE__) + '/lib'

require 'sinatra'
require 'partials'
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

class Testimonial
  attr_accessor :author, :body
  def initialize(author, body) self.author, self.body = author, body end
end

@@testimonials = []
@@testimonials << Testimonial.new('Anonymous', "Your web site is great; it keeps me up to date with all the upcoming auctions. Your auctioneer team is one of the best I've seen so far. All the items I've acquired, I got at an unbeatable price and in excellent condition. My wife and I enjoy attending your auctions. Thanks, and keep up the good work!")
@@testimonials << Testimonial.new('Anonymous', "Your web site is as fine as any I visit. I only get to the Midwest on rare occasion, but like to take in an auction when there. Thanks and keep up the good work.")
@@testimonials << Testimonial.new('Kevin Filko', "I have never submitted a testimonial about an auction company before, but I am so impressed with these people and the way they run their auctions that i just have to let you know what a pleasure it was doing business with them. Their auctions are always on time, the articles for sale are exactly as described, and the best part of all THEY'RE A LOT OF FUN! Thanks for a wonderful experience from start to finish; I can't wait till your next auction! Keep up the good work!")
@@testimonials << Testimonial.new('Tony Mier', "Cooke's is one of the most honest, professional and reputable auctions I have dealt with and I have been extremely pleased! I do long distance business with some of the finest and most prestigious auction houses in the US and have business accounts with many of them. I would urge all to have extreme confidence in all dealings with them!")
@@testimonials << Testimonial.new('Anthony Santolino', "As a former worker for Cooke's, I must say he is one of the most professional businessmen I have met! He's a relentless worker and most of all cares about the buyers needs. In today's market you just don't get that kind of passion and caring anymore! Great job Rick for running an honest business!")
@@testimonials << Testimonial.new('Steven Reinhart', "As a former employee and associate of Cooke's, I can honestly remark that the services provided to the public are top-drawer. Furthermore, Rick is one of the finest auctioneers in the area and has a reputation for putting the customer's best interest at the forefront of his operation and business dealings.")

## CONFIGURATION ###########################
configure :development do
  DataMapper.setup(:default, "sqlite3:dev.db") && DataMapper.auto_migrate!
  DataMapper::Logger.new(STDOUT, :debug)
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
  @title, @body_id = prep 'signup'
  haml :thanks, :layout => !request.xhr?
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
  haml :not_acceptable
end
