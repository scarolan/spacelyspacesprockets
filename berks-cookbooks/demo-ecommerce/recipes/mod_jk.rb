#
# Cookbook Name:: demo-ecommerce
# Recipe:: ssl
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# TODO: Finish refactoring this to enable SSL on CentOS 7

# Build a ROOT webapp directory for the homepage
directory '/usr/share/tomcat/webapps/ROOT' do
  action :create
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
end

template '/usr/share/tomcat/webapps/ROOT/index.html' do
  action :create
  mode '0644'
  source 'index.html.erb'
end

cookbook_file '/usr/share/tomcat/webapps/ROOT/sprockets.png' do
  action :create
  mode '0644'
  source 'sprockets.png'
end

cookbook_file '/usr/share/tomcat/webapps/ROOT/CogswellCogs.jpg' do
  action :create
  mode '0644'
  source 'CogswellCogs.jpg'
end


# Install mod_jk
cookbook_file '/etc/httpd/modules/mod_jk.so' do
  action :create
  mode '0755'
  source 'mod_jk.so'
end

cookbook_file '/etc/httpd/conf.modules.d/00-modjk.conf' do
  action :create
  source '00-modjk.conf'
end

cookbook_file '/etc/httpd/conf.d/tomcat.conf' do
  action :create
  source 'tomcat.conf'
end

service 'tomcat' do
  action :nothing
end

service 'httpd' do
  action :nothing
end

template '/etc/httpd/conf.d/workers.properties' do
  action :create
  source 'workers.properties.erb'
  notifies :restart, 'service[httpd]'
end

template '/etc/tomcat/server.xml' do
  action :create
  source 'server.xml.erb'
  notifies :restart, 'service[tomcat]'
end
