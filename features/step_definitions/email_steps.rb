Then /^"([^\"]*)" should receive a request email$/ do |host_name|
  host = Host.first(:name => host_name)
  debugger
  assert Mail::TestMailer.deliveries.any? {|email|
    email.to.include?(host.email)
  }
end
