require "rubygems"
require "dm-core"
$:.unshift File.join(File.dirname(__FILE__), "../lib/models")
require "host"
require "room"
require "guest"

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'postgres://localhost/stay_with_a_local')
DataMapper.auto_migrate!

hosts = YAML.load(File.read(File.join(File.dirname(__FILE__), "hosts.yml")))
hosts.each do |h|
  host = Host.create :name => h["name"]
  h["rooms"].to_i.times do
    host.rooms.create
  end
end

guests = File.read(File.join(File.dirname(__FILE__), "guests.txt"))
guests.each do |line|
  begin
    name, twitter = line.split('@')
    unless twitter.to_s.strip == ''
      Guest.create :name => name, :twitter => twitter
    end
  rescue Exception => ex
    puts "Problem with #{line}: #{ex.class} - #{ex.message}"
  end
end
