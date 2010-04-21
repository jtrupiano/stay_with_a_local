ENV['RACK_ENV'] ||= 'cucumber'
#$:.unshift(File.join(File.dirname(__FILE__), '..', '..'))
require File.join(File.dirname(__FILE__), '..', '..', 'app')

configure :cucumber do
  require 'features/support/fake_twitter'
  use FakeTwitter

  require 'tlsmail'
  Mail.defaults do
    delivery_method :test
  end
  
  # Monkeypatch mail to include modules it's already included!
  # Only a problem in cucumber.
  # TODO: follow up with @raasdnil and figure out what's up
  Mail::FromField.send(:include, Mail::CommonAddress)
  Mail::ToField.send(:include, Mail::CommonAddress)
  Mail::SubjectField.send(:include, Mail::CommonField)
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

# would think that Rack::MockResponse would already define this.
# Required for rack-test's follow_redirect!
module Rack
  class MockResponse
    def redirect?
      @status >= 300 && @status < 400
    end
  end
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

Before do
  Guest.all.destroy!
  Host.all.destroy!
  RoomRequest.all.destroy!
end

After do
  Mail::TestMailer.deliveries.clear
end