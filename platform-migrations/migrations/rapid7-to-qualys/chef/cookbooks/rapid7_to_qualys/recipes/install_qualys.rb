#
# install_qualys.rb
# Install + activate Qualys Cloud Agent (enterprise flow)
#

write_migration_log("Starting Qualys installation")

# Load data bag item (agents/qualys)
begin
  bag = data_bag_item('agents', 'qualys')
rescue
  bag = nil
end

# Prefer data_bag values; fall back to attributes
pkg_url = (bag && bag['package_url']) ? bag['package_url'] : node['qualys']['package_url']
activation_id = (bag && bag['activation_id']) ? bag['activation_id'] : node['qualys']['activation_id']
customer_id = (bag && bag['customer_id']) ? bag['customer_id'] : node['qualys']['customer_id']

if pkg_url.nil? || activation_id.nil? || customer_id.nil?
  migration_failed("Qualys", "Missing package_url/activation_id/customer_id")
  raise "Qualys package_url or activation/customer IDs not provided"
end

# Download package
remote_file '/tmp/qualys.rpm' do
  source pkg_url
  mode '0644'
  action :create
end

# Install package
package 'qualys-cloud-agent' do
  source '/tmp/qualys.rpm'
  action :install
end

# Activate (vendor cli path may differ; use safe wrapper)
execute 'qualys-activate' do
  command %Q{/usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=#{activation_id} CustomerId=#{customer_id}}
  environment 'PATH' => '/usr/local/bin:/usr/bin:/bin'
  returns [0,1]
  action :run
  ignore_failure false
end

# Ensure service enabled + started
service node['qualys']['service_name'] do
  action [:enable, :start]
  supports status: true, restart: true
end

write_migration_log("Qualys installation & activation finished")
