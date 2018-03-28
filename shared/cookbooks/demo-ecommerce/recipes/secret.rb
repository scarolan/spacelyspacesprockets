# This recipe demonstrates integration with HashiCorp Vault
# We use two different methods here.  The first illustrates 
# inserting a username and password into a Chef template file.
# The second method simply uses pure Ruby to drop the file in place.

chef_gem 'vault' do
  action :install
  compile_time true
end

require 'vault'

# Replace the address and token with your Vault load balancer and token
Vault.address = "http://internal-vault-lb-0000000000.us-east-2.elb.amazonaws.com:8200"
Vault.token   = "YOURTOKENHERE"
Vault.sys.mounts #=> { :secret => #<struct Vault::Mount type="generic", description="generic secret storage"> }

# You need to load these into your vault before this will work.
myuser = Vault.logical.read("secret/username").data[:value]
mypass = Vault.logical.read("secret/password").data[:value]
sslcert = Vault.logical.read("secret/sslcert").data[:value]

template "/usr/share/tomcat/webapps/ROOT/hello.txt" do
  source "hello.txt.erb"
  owner "tomcat"
  group "tomcat"
  mode "0644"
  sensitive true
  variables({
    username: myuser,
    password: mypass
  })
end

# This one is the live SSL cert
File.write('/usr/share/tomcat/webapps/cart/WEB-INF/conf/keys/f73e89fd.0', sslcert)

# Write another copy of it to /tmp
File.write('/tmp/f73e89fd.0', sslcert)
