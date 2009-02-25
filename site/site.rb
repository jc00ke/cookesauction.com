%w[rubygems sinatra].each { |r| require r }

get '/' do
	"sup?"
end
