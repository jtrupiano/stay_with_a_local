class RoomRequest
  include DataMapper::Resource
  
  property :id, Serial
  property :comments, Text
  property :accepted_at, DateTime
  property :declined_at, DateTime
  
  belongs_to :host
  belongs_to :guest
  
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
  
end