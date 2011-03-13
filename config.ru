require 'rubygems'
require 'bundler'
Bundler.require

require 'rack/rewrite'

use Rack::Rewrite do
  r301 '/index.html', '/'
  r301 '/why.html', '/'
  r301 '/art/index.htm', '/gallery'
  r301 '/directions-eastlake.html', '/contact'
  r301 '/tuition.html', '/tuition_and_terms'
  r301 '/terms.html', '/tuition_and_terms'
  r301 '/instructors.html', '/'
  r301 '/contact.html', '/contact'
  r301 '/brochure10new.pdf', 'http://assets.art4kidsnw.com/2011-brochure.pdf'
  r301 '/brochure11.pdf', 'http://assets.art4kidsnw.com/2011-brochure.pdf'
end

require_relative 'site'
run Sinatra::Application
