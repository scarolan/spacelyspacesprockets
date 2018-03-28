#
# Cookbook Name:: demo-ecommerce
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Disable SELinux
execute 'Disable SELinux' do
  command "echo 'SELINUX=disabled' > /etc/sysconfig/selinux; setenforce 0"
end

# The default recipe gets you the entire stack
include_recipe 'demo-ecommerce::java'
include_recipe 'demo-ecommerce::mysql'
include_recipe 'demo-ecommerce::tomcat'
include_recipe 'demo-ecommerce::cart'
include_recipe 'demo-ecommerce::apache'
include_recipe 'demo-ecommerce::mod_jk'
