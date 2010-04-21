hosts = YAML.load(File.read(File.join(File.dirname(__FILE__), "hosts.yml")))
hosts.each do |h|
  host = Host.create h
end

g = Guest.create!(:name => 'John Trupiano', :twitter => 'jtrupiano')