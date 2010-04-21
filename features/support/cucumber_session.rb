# Mock middleware used to simulate being logged in via twitter
class CucumberSession
  def initialize(app)
    @app = app
  end
  
  def call(env)
    env["rack.session"][:guest_id] = env["GUEST"]
    @app.call(env)
  end
end

module CucumberSessionHelpers
  def get_env 
    @guest.nil? ? {} : {"GUEST" => @guest.id}
  end
end
World(CucumberSessionHelpers)