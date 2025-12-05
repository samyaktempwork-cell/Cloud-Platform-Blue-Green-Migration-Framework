#
# validate.rb
# Validate Qualys agent is running and healthy
#

write_migration_log("Starting validation for Qualys agent")

ruby_block "validate_qualys_running" do
  block do
    delay = node['migration']['validate_delay'] || 25
    retries = node['migration']['max_retries'] || 3
    success = false

    retries.times do |i|
      sleep delay
      cmd = Mixlib::ShellOut.new("systemctl is-active #{node['qualys']['service_name']} || true")
      cmd.run_command
      out = cmd.stdout.to_s.strip
      if out == 'active'
        success = true
        break
      else
        Chef::Log.info("Qualys service not active yet (attempt #{i+1}/#{retries}), status=#{out}")
      end
    end

    unless success
      raise "Qualys service did not become active"
    end
  end
  action :run
  notifies :run, 'ruby_block[migration_success_marker]', :immediately
  notifies :run, 'ruby_block[migration_post_validate]', :immediately
end

ruby_block "migration_success_marker" do
  block do
    migration_success("Qualys")
  end
  action :nothing
end

ruby_block "migration_post_validate" do
  block do
    write_migration_log("Validation completed successfully for Qualys")
  end
  action :nothing
end

ruby_block "write_rollback_trigger" do
  block do
    File.open("#{node['migration']['status_dir']}/rollback_trigger", "w") do |f|
      f.puts("qualys_validation_failed")
    end
  end
  action :run
end
