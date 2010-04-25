Given /^I am not authenticated$/ do
  post "/logout"
end

When /^I authenticate with twitter as "([^\"]*)"$/ do |twitter_name|
  guest = find_or_create_guest(twitter_name)
  get "/twitter/#{guest.id}"
end
