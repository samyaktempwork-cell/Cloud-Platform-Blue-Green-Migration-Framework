#
# rollback.rb
# Restores Rapid7 agent if migration fails.
# Removes Qualys agent, reinstalls Rapid7, writes rollback status.
#

log_dir     = node['migration']['log_dir'] || '/opt/migration/logs'
status_dir  = node['migration']['status_dir'] || '/opt/migration/status'
rollback_log = "#{log_dir}/rollback.log"

ruby_block "rollback-start-log" do
  block do
    File.open(rollback_log, "a") { |f| f.puts("#{Time.now} - Starting rollback process") }
  end
end

# -------------------------------
# Remove Qualys Cloud Agent
# -------------------------------
execute "remove-qualys" do
  command "rpm -e qualys-cloud-agent || true"
  action :run
  notifies :run, "ruby_block[log_qualys_removed]"
end

ruby_block "log_qualys_removed" do
  block do
    File.open(rollback_log, "a") { |f| f.puts("#{Time.now} - Qualys agent removed") }
  end
  action :nothing
end

# -------------------------------
# Reinstall Rapid7
# -------------------------------
bag = data_bag_item('agents', 'rapid7') rescue nil
r7_pkg_url = bag ? bag['install_url'] : nil

if r7_pkg_url
  remote_file "/tmp/rapid7.rpm" do
    source r7_pkg_url
    mode "0644"
  end

  package "insight-agent" do
    source "/tmp/rapid7.rpm"
    action :install
  end
end

service "ir_agent" do
  action [:enable, :start]
end

ruby_block "log_r7_reinstall" do
  block do
    File.open(rollback_log, "a") { |f| f.puts("#{Time.now} - Rapid7 agent reinstalled & service started") }
  end
  action :run
end

# -------------------------------
# Write rollback status file
# -------------------------------
file "#{status_dir}/rapid7_to_qualys_rollback.json" do
  content <<-EOF
{
  "module": "rapid7_to_qualys",
  "action": "rollback",
  "status": "rolled_back",
  "timestamp": "#{Time.now.utc}"
}
  EOF
  mode "0644"
end

ruby_block "rollback-end-log" do
  block do
    File.open(rollback_log, "a") { |f| f.puts("#{Time.now} - Rollback completed") }
  end
end
