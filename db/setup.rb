require "dm-core"
require 'dm-serializer'

# Load models
$:.unshift File.join(File.dirname(__FILE__), "../lib/models")
require "host"
require "guest"
require "room_request"

configure :development, :test, :cucumber do
  DataMapper::Logger.new($stdout, :debug)
  # DataMapper.setup(:default, 'postgres://localhost/stay_with_a_local')
  DataMapper.setup(:default, 'mysql://localhost/stay_with_a_local')
end

configure :production do
  load 'db/config.rb'
end
