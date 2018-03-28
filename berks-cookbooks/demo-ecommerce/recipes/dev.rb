#
# Cookbook Name:: demo-ecommerce
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Disable SELinux
execute 'Disable SELinux' do
  command "echo 'SELINUX=disabled' > /etc/sysconfig/selinux; setenforce 0"
end

# Install Apache, configure homepage
include_recipe 'demo-ecommerce::apache'
