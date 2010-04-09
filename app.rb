# Load before Sinatra
require 'rubygems'
require 'compass' # must be loaded before sinatra

# Load Sinatra
require 'sinatra'
require 'lib/render_partial'

# Load after Sinatra -- Move to geminstaller / bundler
require 'haml' # must be loaded after sinatra
require 'compass'
require 'ninesixty'

# Configure Compass
configure do
  Compass.configuration.parse(File.join(Sinatra::Application.root, 'config.rb'))
  enable :sessions
end

# Load models
# WARNING: This will always rebuild the whole database
require File.join(File.dirname(__FILE__), 'db/seeds')

# At a minimum the main sass file must reside within the views directory
# We create /views/stylesheets where all our sass files can safely reside
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

get '/' do
  haml :index, :layout => :'layouts/page'
end

get '/map' do
  haml :map, :layout => :'/layouts/page'
end

get '/hosts/:id/room_requests/new' do
  # TODO: Do "Sign in with Twitter" to really get this
  screen_name_from_twitter = "dhh"
  session[:guest_id] = Guest.first(:twitter => screen_name_from_twitter).id
  @host = Host.get(params[:id])
  haml :'room_requests/new', :layout => :'/layouts/page'
end

post '/hosts/:id/room_requests' do
  @host = Host.get(params[:id])
  @guest = Guest.get(session[:guest_id])
  RoomRequest.create :host => @host, :guest => @guest
  redirect "/"
end
