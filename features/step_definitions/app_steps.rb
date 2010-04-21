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
