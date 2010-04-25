class Guest
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :twitter, String
  property :image_url, String, :size => 100
  
  has n, :room_requests
  
  def booked?
    room_requests.any?(&:accepted?)
  end
  
  def host
    return nil if !booked?
    room_requests.accepted.first.host
  end
end