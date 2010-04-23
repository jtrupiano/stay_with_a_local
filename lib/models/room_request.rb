class RoomRequest
  include DataMapper::Resource
  
  property :id, Serial
  property :email, Text
  property :comments, Text
  property :accepted_at, DateTime
  property :declined_at, DateTime
  property :token, String
  
  belongs_to :host
  belongs_to :guest

  before :create do
    self.token = (0...30).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  
  after :create do
    Mailer.send_request_email(self)
  end
  
  def self.accepted
    all(:accepted_at.not => nil)
  end
  
  def self.pending
    all(:accepted_at => nil, :declined_at => nil)
  end
  
  def pending?
    accepted_at.nil? && declined_at.nil?
  end
  
  def accept
    # TODO: How do you do transactions in DM?
    self.accepted_at = Time.now
    host.available_rooms -= 1
    host.save
    save
  end
  
  def decline
    self.declined_at = Time.now
    save
  end

  after :accept do
    Mailer.send_confirmation_email(self)
    host.room_requests.pending.each(&:decline)    
  end
  
  after :decline do
    Mailer.send_declination_email(self)    
  end
    
end