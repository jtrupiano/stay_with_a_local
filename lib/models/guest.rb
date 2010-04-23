class Guest
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :twitter, String
  
  has 1, :room_request
  
  def booked?
    room_request && room_request.accepted?
  end
end