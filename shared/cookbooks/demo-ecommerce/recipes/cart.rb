#
# Cookbook Name:: demo-ecommerce
# Recipe:: cart
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

ruby_block "fix_encoding" do
  block do
    Encoding.default_internal = nil
  end
end

# Specify mode explicitly to be readable regardless of umask
# This is public but we might want to keep a copy in our own account
remote_file "#{Chef::Config['file_cache_path']}/softslate-3.3.6.war" do
  action :create
  mode '644'
  source 'https://s3-us-west-2.amazonaws.com/bjcpublic/softslate-commerce/softslate-3.3.6.war'
end

# Execute with -a to preserve permissions
execute "Install Shopping Cart" do
  command "cp -a #{Chef::Config['file_cache_path']}/softslate-3.3.6.war /var/lib/tomcat/webapps/cart.war"
  action :run
  not_if { File.exist?("/var/lib/tomcat/webapps/cart.war") }
end

execute "Update permissions on war file" do
  action :run
  command "chown tomcat:tomcat /var/lib/tomcat/webapps/cart.war"
end

service 'tomcat' do
  action :start
end

# Let's just see if we can get tomcat to start.
ruby_block "Sleep my pretty..." do
  block do
    sleep(60)
  end
end

basedir = '/usr/share/tomcat/webapps/cart/WEB-INF'

directory "#{basedir}/src" do
  action :create
end

directory "#{basedir}/classes" do
  action :create
end

%w(appSettings hibernate log4j).each do |f|
  template "#{basedir}/src/#{f}.properties" do
    source "src/#{f}.properties.erb"
    action :create
  end
end

%w(appSettings hibernate log4j).each do |f|
  template "#{basedir}/classes/#{f}.properties" do
    source "classes/#{f}.properties.erb"
    action :create
  end
end

template "#{Chef::Config['file_cache_path']}/backup.sql" do
  action :create
  source 'backup.sql.erb'
  notifies :run, 'execute[restore_database_backup]', :immediately
end

execute "restore_database_backup" do
  command "mysql -u root softslate < #{Chef::Config['file_cache_path']}/backup.sql"
  action :nothing
  notifies :restart, 'service[tomcat]', :delayed
end

%w(f73e89fd.0 sdk-seller.p12 twoWay.key).each do |f|
  cookbook_file "/usr/share/tomcat/webapps/cart/WEB-INF/conf/keys/#{f}" do
    action :create
    source f
  end
end

service 'tomcat' do
  action :restart
end
