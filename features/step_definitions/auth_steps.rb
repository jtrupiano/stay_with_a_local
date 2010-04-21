Given /^I am not authenticated$/ do
  @guest = nil
end

When /^I authenticate with twitter as "([^\"]*)"$/ do |twitter_name|
  @guest = Guest.create!(:twitter => twitter_name, :name => twitter_name)
end
