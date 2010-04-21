# Mock middleware used to simulate being logged in via twitter
class FakeTwitter
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if env["PATH_INFO"] =~ /twitter\/(\d+)/
      env["rack.session"][:guest_id] = $1
      [302, {"Location" => '/'}, ["Successfully authenticated with twitter"]]
    else
      @app.call(env)
    end
  end
end
