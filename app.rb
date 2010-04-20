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
  use Rack::Flash, :sweep => false
end

# Load models
require File.join(File.dirname(__FILE__), 'db/setup')
# TODO: WARNING: This will always rebuild the whole database
require File.join(File.dirname(__FILE__), 'db/seeds')

require 'mailer'
require 'twitter_config'

module TwitterMethods
  def twitter_client
    @twitter_client ||= TwitterOAuth::Client.new(
      :consumer_key => TWITTER_CONSUMER_KEY,
      :consumer_secret => TWITTER_CONSUMER_SECRET
    )
  end

  def login_from_twitter
    twitter_client.authorize(
      session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )

    user_info = twitter_client.info
    guest = Guest.first(:twitter => user_info['screen_name'])
    if guest.nil? && list_members_by_twitter_name.include?(user_info['screen_name'])
      Guest.create!(:twitter => user_info['screen_name'], :name => user_info['name'])
    end
    if guest.nil?
      session.delete(:guest_id)
    else
      session[:guest_id] = guest.id
    end
  rescue OAuth::Unauthorized
    session.delete(:guest_id)
  ensure
    session.delete(:request_token)
    session.delete(:request_token_secret)
  end
  
  def save_token_and_redirect_to_twitter
    request_token = twitter_client.request_token(:oauth_callback => TWITTER_CALLBACK_URL)
    session[:request_token]         = request_token.token
    session[:request_token_secret]  = request_token.secret
    redirect request_token.authorize_url
  end

  def returning_from_twitter?
    params[:oauth_verifier] && session[:request_token]
  end
  
  # can only be called on the same request in which authorization is handled
  def list_members_by_twitter_name
    list_members = twitter_client.list_members('bmoreonrails', 'railsconf-2010-speakers')['users'].map{|user_info| user_info['screen_name']}
  end
  
  def has_access?
    session[:guest_id]
  end
end

include TwitterMethods

# At a minimum the main sass file must reside within the views directory
# We create /views/stylesheets where all our sass files can safely reside
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options)
end

get '/' do
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