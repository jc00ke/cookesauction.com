require 'mongoid'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'models')

EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
require 'page'
require 'listing'
require 'email'
require 'submission'
