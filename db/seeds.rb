require "rubygems"
require "dm-core"
require 'dm-serializer'
$:.unshift File.join(File.dirname(__FILE__), "../lib/models")
require "host"
require "guest"
require "room_request"

configure :development, :test do
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, 'postgres://localhost/stay_with_a_local')
  # DataMapper.setup(:default, 'mysql://localhost/stay_with_a_local')
end

configure :production do
  load 'db/config.rb'
end

DataMapper.auto_migrate!

hosts = YAML.load(File.read(File.join(File.dirname(__FILE__), "hosts.yml")))
hosts.each do |h|
  host = Host.create h
  Guest.create(:twitter => h['twitter'], :image_url => 'http://a3.twimg.com/profile_images/627637055/thumb_gravatar_normal.jpg', :name => h['name'])
end

g = Guest.create!(:name => 'John Trupiano', :twitter => 'jtrupiano', :image_url => 'http://a3.twimg.com/profile_images/627637055/thumb_gravatar_normal.jpg')
guests = File.read(File.join(File.dirname(__FILE__), "guests.txt"))
guests.each do |line|
  begin
    name, twitter = line.split('@')
    unless twitter.to_s.strip == ''
      Guest.create :name => name.to_s.strip, :twitter => twitter.to_s.strip
    end
  rescue Exception => ex
    puts "Problem with #{line}: #{ex.class} - #{ex.message}"
  end
end

# rr = RoomRequest.create(:host => Host.first, :guest => Guest.first)
# rr.accept
