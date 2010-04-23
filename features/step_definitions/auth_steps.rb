Given /^I am not authenticated$/ do
  post "/logout"
end

When /^I authenticate with twitter as "([^\"]*)"$/ do |twitter_name|
  guest = Guest.first(:twitter => twitter_name)
  guest = Guest.create!(:twitter => twitter_name, :name => twitter_name) if guest.nil?
  get "/twitter/#{guest.id}"
end
