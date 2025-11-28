#!/bin/bash
set -e

echo "Installing Chef Client..."

CHEF_URL="https://packages.chef.io/files/stable/chef/18.5.0/el/8/chef-18.5.0-1.el8.x86_64.rpm"

sudo rpm -Uvh $CHEF_URL

echo "Chef Installed:"
chef-client --version
