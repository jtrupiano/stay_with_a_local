class Room
  include DataMapper::Resource
  
  property :id, Serial
  
  belongs_to :host
  belongs_to :guest, :required => false
end