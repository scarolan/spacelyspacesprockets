#
# Cookbook Name:: demo-ecommerce
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'demo-ecommerce::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      stub_command("echo 'show databases' | mysql -u root | grep softslate").and_return(0)
      stub_command("echo 'show tables;' | mysql -u root softslate | grep sscProductSetting").and_return(0)
      stub_command("test -f /etc/ssl/certs/chefspec.automate-demo.com.crt").and_return(0)
      stub_command("test -f /home/ubuntu/chefspec.automate-demo.com.crt").and_return(0)
      expect { chef_run }.to_not raise_error
    end
  end
end
