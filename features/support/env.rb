ENV['RACK_ENV'] ||= 'cucumber'
#$:.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require File.join(File.dirname(__FILE__), '..', '..', 'app')

configure :cucumber do
  require 'features/support/fake_twitter'
  use FakeTwitter
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

World do
  def app
    @app = Rack::Builder.new do
      run Sinatra::Application
    end
  end

  include Test::Unit::Assertions
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end