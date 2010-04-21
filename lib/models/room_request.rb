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
  
  def self.accepted
    all(:accepted_at.not => nil)
  end
  
  def accept
    # TODO: How do you do transactions in DM?
    # TODO: decline/delete all other requests made by the guest
    self.accepted_at = Time.now
    host.available_rooms -= 1
    host.save
    save
  end
  
  def decline
    self.declined_at = Time.now
    save
  end
  
end