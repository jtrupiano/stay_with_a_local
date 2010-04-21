require 'mail'
require 'haml'

# TODO: remove hardcoded refs to localhost:4567
class Mailer
  def self.haml(template, locals={})
    engine = Haml::Engine.new(File.read(File.join(Sinatra::Application.views, "#{template}.haml")))
    engine.render(Object.new, locals)
  end
  
  def self.send_request_email(room_request)
    email_body = haml(:'mailer/room_request', :host => 'http://localhost:4567', :room_request => room_request)
    mail = Mail.new do
      body email_body
      from 'no-reply@localhost.com'
      to room_request.host.email
      subject "A room has been requested by #{room_request.guest.name}"
      content_type "text/html"
    end
    mail.deliver!
  end
  
  def self.send_confirmation_email(room_request)
    email_body = haml(:'mailer/confirmation', :host => 'http://localhost:4567', :room_request => room_request)
    mail = Mail.new do
      body email_body
      from 'no-reply@localhost.com'
      to room_request.email
      subject "#{room_request.host.name} has accepted your room request for RailsConf"
      content_type "text/html"
    end
    mail.deliver!
  end
  
  def self.send_declination_email(room_request)
    email_body = haml(:'mailer/declination', :host => 'http://localhost:4567', :room_request => room_request)
    mail = Mail.new do
      body email_body
      from 'no-reply@localhost.com'
      to room_request.email
      subject "#{room_request.host.name} has declined your room request for RailsConf"
      content_type "text/html"
    end
    mail.deliver!
  end
  
end