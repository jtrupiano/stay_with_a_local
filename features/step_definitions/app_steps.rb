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

When /^"([^\"]*)" approves the reservation request$/ do |host_name|
  host = Host.first(:name => host_name)
  room_request = host.room_requests.last
  get "/room_requests/#{room_request.id}/accept/#{room_request.token}"
  follow_redirect!
end

When /^"([^\"]*)" declines the reservation request$/ do |host_name|
  host = Host.first(:name => host_name)
  room_request = host.room_requests.last
  get "/room_requests/#{room_request.id}/decline/#{room_request.token}"
  follow_redirect!
end
