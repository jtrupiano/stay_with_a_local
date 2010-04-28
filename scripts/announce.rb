require 'rubygems'
require 'twitter'

def client
  @client ||= begin
    httpauth = Twitter::HTTPAuth.new('username', 'password')
    client = Twitter::Base.new(httpauth)
  end
end

def tweet(twitter)
  # client.update("#{twitter} We're hosting Railsconf speakers this year. Find a local Rubyist to stay with: http://bmoreonrails.org/stay-with-a-local")
  puts "@#{twitter} We're hosting Railsconf speakers this year. Find a local Rubyist to stay with: http://bmoreonrails.org/stay-with-a-local"
end

guests = File.read(File.join(File.dirname(__FILE__), "..", "db", "guests.txt"))
guests.each do |line|
  begin
    name, twitter = line.split('@')
    unless (twitter = twitter.to_s.strip) == ''
      tweet(twitter)
    end
  rescue Exception => ex
    puts "Problem with #{line}: #{ex.class} - #{ex.message}"
  end
end