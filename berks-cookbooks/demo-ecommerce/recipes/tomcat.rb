#
# Cookbook Name:: demo-ecommerce
# Recipe:: tomcat
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'tomcat' do
  action :install
end

service 'tomcat' do
  action :enable
end

package 'tomcat-admin-webapps' do
  action :install
end

directory '/usr/share/tomcat/logs' do
  action :create
end