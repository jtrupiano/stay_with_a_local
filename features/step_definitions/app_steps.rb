When /^I view the rooms available$/ do
  get '/'
end

Then /^I should not be able to reserve a room$/ do
  # This is really brittle, but can't think of how to do it better right now
  Then %{I should see /function can_reserve\\\(\\\) \\\{ return false/}
  And  %{I should not see /function can_reserve\\\(\\\) \\\{ return true/}
end

Then /^I should be able to reserve a room$/ do
  Then %{I should see /return true/}
  And  %{I should not see /return false/}
end

When /^I choose to stay with "([^\"]*)"$/ do |host_name|
  host = Host.first(:name => host_name)
  get "/hosts/#{host.id}/room_requests/new"
end

When /^I try to stay with "([^\"]*)"$/ do |host_name|
  host = Host.first(:name => host_name)
  get "/hosts/#{host.id}/room_requests/new"
  follow_redirect!
end


When /^"([^\"]*)" accepts the room request from "([^\"]*)"$/ do |host_name, guest_twitter|
  host = Host.first(:name => host_name)
  guest = Guest.first(:twitter => guest_twitter)
  room_request = RoomRequest.first(:host => host, :guest => guest)
  get "/room_requests/#{room_request.id}/accept/#{room_request.token}"
  follow_redirect!
end

When /^"([^\"]*)" accepts the room request$/ do |host_name|
  host = Host.first(:name => host_name)
  room_request = host.room_requests.last
  get "/room_requests/#{room_request.id}/accept/#{room_request.token}"
  follow_redirect!
end

When /^"([^\"]*)" declines the room request from "([^\"]*)"$/ do |host_name, guest_twitter|
  host = Host.first(:name => host_name)
  guest = Guest.first(:name => guest_twitter)
  room_request = RoomRequest.first(:host => host, :guest => guest)
  get "/room_requests/#{room_request.id}/decline/#{room_request.token}"
  follow_redirect!
end

When /^"([^\"]*)" declines the room request$/ do |host_name|
  host = Host.first(:name => host_name)
  room_request = host.room_requests.last
  get "/room_requests/#{room_request.id}/decline/#{room_request.token}"
  follow_redirect!
end
