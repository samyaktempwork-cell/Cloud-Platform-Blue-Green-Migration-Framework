#
# Cookbook:: base_hardening
# Recipe:: default
#

log 'Starting base hardening...' do
  level :info
end

# ------------------------------------------------------------
# 1. System Update
# ------------------------------------------------------------
if node['base_hardening']['system_update']
  execute 'system-update' do
    command 'dnf update -y'
    action :run
  end
end

# ------------------------------------------------------------
# 2. SSH Hardening
# ------------------------------------------------------------

template '/etc/ssh/sshd_config' do
  source 'sshd_config.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    permit_root_login: node['base_hardening']['ssh']['permit_root_login'],
    password_auth: node['base_hardening']['ssh']['password_auth']
  )
  notifies :restart, 'service[sshd]', :immediately
end

service 'sshd' do
  action :nothing
end

# ------------------------------------------------------------
# 3. Auditd
# ------------------------------------------------------------
if node['base_hardening']['auditd']['enabled']
  service 'auditd' do
    action [:enable, :start]
  end
end

# ------------------------------------------------------------
# 4. Remove insecure packages
# ------------------------------------------------------------
node['base_hardening']['packages']['remove'].each do |pkg|
  package pkg do
    action :remove
  end
end

# ------------------------------------------------------------
# 5. Sysctl Hardening (Optional extensible)
# ------------------------------------------------------------
node['base_hardening']['sysctl'].each do |key, value|
  sysctl key do
    value value
    action :apply
  end
end

log 'Base hardening completed successfully' do
  level :info
end
