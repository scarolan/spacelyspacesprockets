#!/bin/sh
rm -rf ./berks-cookbooks/*
berks install -b ./shared/cookbooks/demo-ecommerce/Berksfile
berks vendor -b ./shared/cookbooks/demo-ecommerce/Berksfile
