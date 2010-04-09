class Guest
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :twitter, String
  
  has 1, :room_request
end