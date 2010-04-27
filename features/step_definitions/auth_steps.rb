Given /^I am not authenticated$/ do
  get "/logout"
end

When /^I authenticate with twitter as "([^\"]*)"$/ do |twitter_name|
  guest = find_or_create_guest(twitter_name)
  get "/twitter/#{guest.id}"
end

When /^I authenticate with twitter as "([^\"]*)" but am not a host$/ do |twitter_name|
  get "/twitter_fail/#{twitter_name}"
end
