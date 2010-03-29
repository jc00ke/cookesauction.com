require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-types'

models_dir = File.join(File.dirname(__FILE__), 'models')

require File.join(models_dir, 'page')
require File.join(models_dir, 'listing')
require File.join(models_dir, 'email')
require File.join(models_dir, 'submission')


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
