TWITTER_CONSUMER_KEY      = 'A4slsVEhbSjEqmRkGDudw'
TWITTER_CONSUMER_SECRET   = 'Bh9jGXYe7MXVCIFp0rcTYfvWCPUnFXvtBwBthONdao'

configure :development do
  TWITTER_CALLBACK_URL      = 'http://localhost:4567/twitter_callback'
end
configure :production do
  TWITTER_CALLBACK_URL      = 'http://stay-with-a-local.slslabs.com/twitter_callback'
end

require 'twitter_oauth'

module TwitterAuth
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
      Guest.create!(:twitter => user_info['screen_name'], :name => user_info['name'], :image_url => user_info['profile_image_url'])
    end
    if guest.nil?
      session.delete(:guest_id)
      flash[:error] = "@#{user_info['screen_name']} is not on our list of speakers. Please tweet <a href='http://twitter.com/bmoreonrails'>@bmoreonrails</a> if you should be on the list."
    else
      session[:guest_id] = guest.id
      flash[:notice] = "You have successfully authenticated with twitter as a speaker."
    end
  rescue OAuth::Unauthorized
    session.delete(:guest_id)
    flash[:error] = "Twitter was unable to authenticate you."
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
  
  def logged_in?
    session[:guest_id]
  end
end
