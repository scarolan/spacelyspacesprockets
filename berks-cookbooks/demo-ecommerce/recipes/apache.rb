#
# Cookbook Name:: demo-ecommerce
# Recipe:: java
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'httpd' do
  action :install
end

service 'httpd' do
  action [ :start, :enable ]
end

template '/var/www/html/index.html' do
  action :create
  mode '0644'
  source 'index.html.erb'
end

cookbook_file '/var/www/html/sprockets.png' do
  action :create
  mode '0644'
  source 'sprockets.png'
end

cookbook_file '/var/www/html/CogswellCogs.jpg' do
  action :create
  mode '0644'
  source 'CogswellCogs.jpg'
end