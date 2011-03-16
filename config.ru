require 'rubygems'
require 'bundler'
Bundler.require

require 'rack/rewrite'

use Rack::Rewrite do
  r301 '/AboutUs.cfm', '/'
  r301 '/Business.cfm', '/'
  r301 '/ContactUs.cfm', '/contact-us'
  r301 '/EmailList.cfm', '/signup'
  r301 '/FAQ.cfm', '/'
  r301 '/index.cfm', '/'
  r301 '/PastSales.cfm', '/past-sales'
  r301 '/PictureGallery.cfm', '/'
  r301 '/PrivacyPolicy.cfm', '/privacy'
  r301 '/Testimonials.cfm', '/testimonials'
end

require './site'
run Sinatra::Application
