require 'rubygems'
require 'bundler'
Bundler.setup

# Load before Sinatra
require 'compass' # must be loaded before sinatra

# Load Sinatra
require 'sinatra'
require 'lib/render_partial'

# Load after Sinatra -- Move to geminstaller / bundler
require 'haml' # must be loaded after sinatra
require 'ninesixty'

configure do
  Compass.configuration.parse(File.join(Sinatra::Application.root, 'config.rb'))
  enable :sessions
  require 'rack/flash'
  use Rack::Flash, :sweep => true
end

# Load models
require File.join(File.dirname(__FILE__), 'db/setup')
# TODO: WARNING: This will always rebuild the whole database
require File.join(File.dirname(__FILE__), 'db/seeds')

require 'mailer'
require 'twitter_config'

def login_from_twitter
  get_access_token_from_session if !session[:access_token]  
  if session[:access_token]
    require 'ruby-debug'
    debugger
  end
end

def get_access_token_from_session
  consumer = OAuth::Consumer.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :site => TWITTER_URL)
  request_token = OAuth::RequestToken.new(consumer, session[:twitter_request_token], session[:twitter_request_secret])
  access_token = request_token.get_access_token
  session[:access_token] = access_token
rescue OAuth::Unauthorized
  require 'ruby-debug'
  debugger
  session.delete(:access_token)
ensure
  session.delete(:twitter_request_token)
  session.delete(:twitter_request_secret)
end

def save_token_and_redirect_to_twitter
  consumer = OAuth::Consumer.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, :site => TWITTER_URL)
  request_token = consumer.get_request_token(:oauth_callback => TWITTER_CALLBACK_URL)
  session[:twitter_request_token] = request_token.token
  session[:twitter_request_secret] = request_token.secret
  redirect request_token.authorize_url
end

def has_access?
  
end

# At a minimum the main sass file must reside within the views directory
# We create /views/stylesheets where all our sass files can safely reside
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

get '/' do
  login_from_twitter
  haml :index, :layout => :'/layouts/page'
end

get '/twitter' do
  save_token_and_redirect_to_twitter
end

get '/hosts/:id/room_requests/new' do
  @host = Host.get(params[:id])
  if @host.available_rooms.zero?
    flash[:error] = "#{@host.name} no longer has any rooms available."
    redirect "/"
    return
  end
  # TODO: Do "Sign in with Twitter" to really get this
  screen_name_from_twitter = "dhh"
  session[:guest_id] = Guest.first(:twitter => screen_name_from_twitter).id
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
  room_request = RoomRequest.create :host => host, :guest => guest, :comments => params[:comments]
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