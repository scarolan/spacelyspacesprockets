#
# Cookbook Name:: demo-ecommerce
# Recipe:: mysql
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'mariadb' do
  action :install
end

package 'mariadb-server' do
  action :install
end

service 'mariadb' do
  action [ :start, :enable ]
end

execute 'Add ecommerce database' do
  command "echo 'create database softslate' | mysql -u root"
  action :run
  not_if "echo 'show databases' | mysql -u root | grep softslate"
end
