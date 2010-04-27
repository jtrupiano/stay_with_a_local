# Mock middleware used to simulate being logged in via twitter
class FakeTwitter
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if env["PATH_INFO"] =~ /twitter\/(\d+)/
      env["rack.session"][:guest_id] = $1
      [302, {"Location" => '/'}, ["Successfully authenticated with twitter"]]
    elsif env["PATH_INFO"] =~ /twitter_fail\/(\w+)/
      env["x-rack.flash"][:error] = "@#{$1} is not on our list of speakers"
      [302, {"Location" => '/'}, ["Unsuccessfully authenticated with twitter"]]
    else
      @app.call(env)
    end
  end
end
