#
# Cookbook:: bootstrap
# Recipe:: default
#

log 'Bootstrap started for baseline AMI' do
  level :info
end

# ---------------------------------------------------------
# 1. Install and enable SSM Agent (only if enabled=true)
# ---------------------------------------------------------
if node['bootstrap']['ssm']['enabled']
  package node['bootstrap']['ssm']['package'] do
    action :install
  end

  service node['bootstrap']['ssm']['service'] do
    action [:enable, :start]
  end
end

# ---------------------------------------------------------
# 2. Create platform user
# ---------------------------------------------------------
user node['bootstrap']['platform_user']['name'] do
  shell node['bootstrap']['platform_user']['shell']
  manage_home true
  home node['bootstrap']['platform_user']['home']
end

# ---------------------------------------------------------
# 3. Create directories
# ---------------------------------------------------------
node['bootstrap']['directories'].each do |dir|
  directory dir do
    owner node['bootstrap']['platform_user']['name']
    group node['bootstrap']['platform_user']['name']
    mode '0755'
    recursive true
    action :create
  end
end

# ---------------------------------------------------------
# 4. Create bootstrap completion file
# ---------------------------------------------------------
file node['bootstrap']['status_file'] do
  content "Bootstrap completed at #{Time.now}\n"
  owner node['bootstrap']['platform_user']['name']
  mode '0644'
  action :create
end

log 'Bootstrap completed for baseline AMI' do
  level :info
end
