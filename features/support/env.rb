ENV['RACK_ENV'] ||= 'cucumber'
#$:.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require File.join(File.dirname(__FILE__), '..', '..', 'app')

configure :cucumber do
  require 'features/support/cucumber_session'
  use CucumberSession
end

# # Force the application name because polyglot breaks the auto-detection logic.
# Sinatra::Application.app_file = app_file
# 
# require 'spec/expectations'
require 'test/unit'
require 'rack/test'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rack
end

class MyWorld
  include Test::Unit::Assertions
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end
end

World{MyWorld.new}