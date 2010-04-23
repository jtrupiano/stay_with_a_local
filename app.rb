require 'rubygems'
require 'bundler'
Bundler.setup

# Load before Sinatra
require 'compass' # must be loaded before sinatra

# Load Sinatra
require 'sinatra'
# TODO: Google analytics
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
require 'db/setup'
configure :development, :cucumber do
  require 'ruby-debug'
  DataMapper.auto_migrate!
end

require 'mailer'
configure :development do
  require 'db/seeds'
  require 'lib/mail_hijack'
end

require 'lib/twitter_auth'
include TwitterAuth

def booked?
  @guest = Guest.get(session[:guest_id])
  @guest && @guest.booked?
end

def can_reserve?
  logged_in? && !booked?
end

def require_unbooked_guest
  return true if logged_in? && !booked?
  if !logged_in?
    flash[:error] = "You must be logged into twitter as a registered speaker to reserve a room."
  elsif booked?
    flash[:error] = "You've already booked a room!"
  end
  redirect "/"
  halt
end

def require_unbooked_host
  @host = Host.get(params[:id])
  if @host.available_rooms < 1    
    flash[:error] = "#{@host.name} no longer has any rooms available."
    redirect "/"
    halt
  end
end

# At a minimum the main sass file must reside within the views directory
# We create /views/stylesheets where all our sass files can safely reside
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

# TODO: ensure that users cannot submit more than one request (or add support for more than one in the database/validations)
get '/' do
  login_from_twitter
  @can_reserve  = can_reserve?
  @logged_in    = logged_in?
  haml :index, :layout => :'/layouts/page'
end

get '/twitter' do
  save_token_and_redirect_to_twitter
end

# TODO: provide a log out link in the UI
post '/logout' do
  session.delete(:guest_id)
  redirect "/"
end

# TODO: refactor out checks for can_reserve? for all of these actions
get '/hosts/:id/room_requests/new' do
  require_unbooked_guest
  require_unbooked_host
  haml :'room_requests/new', :layout => :'/layouts/page'
end

post '/hosts/:id/room_requests' do
  require_unbooked_guest
  require_unbooked_host
  room_request = RoomRequest.create :host => @host, :guest => @guest, :comments => params[:comments], :email => params[:email]
  flash[:notice] = "You have submitted a room request to #{@host.name}.  You will receive email confirmation when the request has been accepted or declined."
  redirect "/"
end

get '/room_requests/:id/accept/:token' do
  room_request = RoomRequest.get(params[:id])
  if room_request.host.available_rooms < 1
    flash[:error] = "You have already approved room requests for all of your rooms"
  elsif !room_request.pending?
    flash[:error] = "You have already processed the room request from #{room_request.guest.twitter}"
  elsif room_request.token != params[:token]
    flash[:error] = "Unable to find this request"
  else
    room_request.accept
    flash[:notice] = "You have accepted a room request from #{room_request.guest.name}.  Rooms you have available: #{room_request.host.available_rooms}"
  end
  redirect "/"
end

get '/room_requests/:id/decline/:token' do
  room_request = RoomRequest.get(params[:id])
  if !room_request.pending?
    flash[:error] = "You have already processed the room request from #{room_request.guest.twitter}"
  elsif room_request.token != params[:token]
    flash[:error] = "Unable to find this request"
  else
    room_request.decline
    flash[:notice] = "You have declined a room request from #{room_request.guest.name}.  Rooms you have available: #{room_request.host.available_rooms}"
  end
  redirect "/"
end