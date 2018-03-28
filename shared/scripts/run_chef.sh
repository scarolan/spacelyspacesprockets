#!/bin/bash
sudo yum -y install git
cd /tmp
# Use this format for a public repo
# git clone http://github.com/scarolan/projectk
# Use this format for a private repo
git clone https://scarolan:YOURTOKENORPASSWORD@github.com/scarolan/projectk.git
berks install -b /tmp/projectk/shared/cookbooks/demo-ecommerce/Berksfile
berks vendor -b /tmp/projectk/shared/cookbooks/demo-ecommerce/Berksfile
mv /tmp/berks-cookbooks /tmp/cookbooks
sudo chef-client -z -o demo-ecommerce