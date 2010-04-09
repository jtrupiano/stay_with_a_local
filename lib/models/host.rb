class Host
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :lat, Float
  property :lon, Float
  
  has n, :rooms
  
  def image_path
    "/images/hosts/#{name.to_s.gsub(' ','_').downcase}.jpg"
  end
  
end