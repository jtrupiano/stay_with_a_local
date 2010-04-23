Then /^"([^\"]*)" should receive a request email$/ do |host_name|
  host = Host.first(:name => host_name)
  assert Mail::TestMailer.deliveries.any? {|email|
    email.to.include?(host.email)
  }
end

Then /^"([^\"]*)" should receive a confirmation email$/ do |guest_twitter|
  guest = Guest.first(:twitter => guest_twitter)
  assert Mail::TestMailer.deliveries.any? {|email|
    email.to.include?(guest.room_request.email)
  }
end

Then /^"([^\"]*)" should receive a declination email$/ do |guest_twitter|
  guest = Guest.first(:twitter => guest_twitter)
  assert Mail::TestMailer.deliveries.any? {|email|
    email.to.include?(guest.room_request.email)
  }
end
