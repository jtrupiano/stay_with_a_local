When /^I view the rooms available$/ do
  get '/'
end

Then /^I should not be able to reserve a room$/ do
  # testing that js function is_logged_in() returns false

  # This is really brittle, but can't think of how to do it better right now
  Then %{I should see /return false/}
  And  %{I should not see /return true/}
  # Then %{I should see /function is_logged_on\(\) \{\\n.+return false/}
end

Then /^I should be able to reserve a room$/ do
  Then %{I should see /return true/}
  And  %{I should not see /return false/}
end

When /^I choose to "Stay with Dave"$/ do
  host = Host.first(:name => 'Dave Troy')
  get "/hosts/#{host.id}/room_requests/new"
end

Then /^"([^\"]*)" should receive a request email$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^\"]*)" approves the reservation request$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^"([^\"]*)" should receive a confirmation email$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^I view the rooms available for "([^\"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^"([^\"]*)" should be listed as staying with "([^\"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^\"]*)" has submitted a reservation request$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^"([^\"]*)" rejects the reservation request$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^"([^\"]*)" should receive a rejection email$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
