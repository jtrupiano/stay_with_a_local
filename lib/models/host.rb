class Host
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :lat, Float
  property :lon, Float
  
  has n, :rooms
end