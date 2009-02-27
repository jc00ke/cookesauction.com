%w[rubygems sinatra].each { |r| require r }

get '/' do
	haml :index
end

get '/master.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :master  
end


get '/:page' do
  haml params[:page].intern
end
