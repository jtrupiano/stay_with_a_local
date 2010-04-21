require 'rubygems'
# require 'bundler'
# Bundler.setup

# Load before Sinatra
require 'compass' # must be loaded before sinatra

# Load Sinatra
require 'sinatra'
require 'lib/render_partial'

require 'haml' # must be loaded after sinatra
require 'ninesixty'

# Set Sinatra's variables (cucumber needs them)
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public, 'public'

configure do
  Compass.configuration.parse(File.join(Sinatra::Application.root, 'config.rb'))
  enable :sessions
  require 'rack/flash'
  use Rack::Flash, :sweep => false
end

# Load models
require File.join(File.dirname(__FILE__), 'db/setup')
configure :development, :cucumber do
  require 'ruby-debug'
  DataMapper.auto_migrate!
end

configure :development, :cucumber do
  require File.join(File.dirname(__FILE__), 'db/seeds')
end

require 'mailer'
require 'twitter_auth'
include TwitterAuth

# At a minimum the main sass file must reside within the views directory
# We create /views/stylesheets where all our sass files can safely reside
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

get '/' do
  # debugger
  login_from_twitter
  @has_access = has_access?
  haml :index, :layout => :'/layouts/page'
end

get '/twitter' do
  save_token_and_redirect_to_twitter
end

get '/hosts/:id/room_requests/new' do
  if !has_access?
    flash[:error] = "You must be logged into twitter as a registered speaker to reserve a room."
    redirect "/"
    return
  end
  @host = Host.get(params[:id])
  if @host.available_rooms.zero?
    flash[:error] = "#{@host.name} no longer has any rooms available."
    redirect "/"
    return
  end
  haml :'room_requests/new', :layout => :'/layouts/page'
end

post '/hosts/:id/room_requests' do
  host = Host.get(params[:id])
  if host.available_rooms.zero?
    flash[:error] = "#{host.name} no longer has any rooms available."
    redirect "/"
    return
  end
  guest = Guest.get(session[:guest_id])
  room_request = RoomRequest.create :host => host, :guest => guest, :comments => params[:comments], :email => params[:email]
  Mailer.send_request_email(room_request)
  flash[:notice] = "You have submitted a room request to #{host.name}.  You will receive email confirmation when the request has been accepted or declined."
  redirect "/"
end

get '/room_requests/:id/accept/:token' do
  room_request = RoomRequest.get(params[:id])
  if room_request.token != params[:token]
    return "Unable to find this request"
  end
  room_request.accept
  # TODO: send email
  flash[:notice] = "You have accepted a room request from #{room_request.guest.name}.  Rooms you have available: #{room_request.host.available_rooms}"
  redirect "/"
end

get '/room_requests/:id/decline/:token' do
  room_request = RoomRequest.get(params[:id])
  if room_request.token != params[:token]
    return "Unable to find this request"
  end
  room_request.decline
  # TODO: send email
  flash[:notice] = "You have declined a room request from #{room_request.guest.name}.  Rooms you have available: #{room_request.host.available_rooms}"
  redirect "/"
end