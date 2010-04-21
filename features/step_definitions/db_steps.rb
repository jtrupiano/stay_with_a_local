Given /^a host "([^\"]*)" with (\d+) available room(?:|s)$/ do |host_name, rooms|
  Host.create!(:name => host_name, :email => "#{host_name.gsub(' ', '_')}@localhost.com", :available_rooms => rooms)
end

Then /^"([^\"]*)" should have (\d+) available room(?:|s)$/ do |host, rooms|
  host = Host.first(:name => host)
  assert_equal rooms.to_i, host.available_rooms
end

Then /^"([^\"]*)" should be staying with "([^\"]*)"$/ do |guest_twitter, host|
  guest = Guest.first(:twitter => guest_twitter)
  host = Host.first(:name => host)
  room_request = RoomRequest.first(:host => host, :guest => guest, :accepted_at.not => nil)
  assert_not_nil room_request
end

Given /^"([^\"]*)" has submitted a room request to "([^\"]*)"$/ do |guest_twitter, host|
  guest = Guest.create!(:twitter => guest_twitter, :name => guest_twitter)
  host = Host.first(:name => host)
  host = Host.create!(:twitter => 'abc', :name => host, :email => "#{host.gsub(' ', '_')}@localhost.com") if host.nil?
  rr = RoomRequest.create(:guest => guest, :host => host, :email => "#{guest_twitter}@localhost.com")
  assert_not_nil rr.token
end
