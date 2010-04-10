class Host
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :lat, Float
  property :lon, Float
  property :available_rooms, Integer
  property :description, String, :length => 2000
  
  has n, :room_requests
  
  def image_path
    "/images/hosts/#{name.to_s.gsub(' ','_').downcase}.jpg"
  end
  
  def first_name
    name.split[0]
  end
  
  def guests
    room_requests.accepted.guest
  end
  
end