require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'
require 'dm-migrations'
require 'dm-is-remixable'

$:.unshift File.join(File.dirname(__FILE__), 'models')

require 'page'
require 'listing'
require 'email'
require 'submission'


class DataMapper::Validate::ValidationErrors
    def to_html
        output  = []
        output  << "<ul>"
        self.each do |error|
            error.each{ |e| output << "<li>#{e}</li>" }
        end
        output << "</ul>"
        output.join("\n")
    end
end

DataMapper.finalize
