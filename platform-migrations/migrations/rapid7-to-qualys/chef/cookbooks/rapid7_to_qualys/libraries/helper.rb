#
# MigrationHelper - helper methods used by recipes
#
module MigrationHelper
  require 'mixlib/shellout'

  def pkg_installed?(pkg)
    cmd = Mixlib::ShellOut.new("rpm -q #{pkg}")
    cmd.run_command
    cmd.exitstatus == 0
  rescue
    false
  end

  def service_running?(svc)
    cmd = Mixlib::ShellOut.new("systemctl is-active #{svc}")
    cmd.run_command
    cmd.stdout.to_s.strip == 'active'
  rescue
    false
  end

  def stop_service(svc, timeout: 30)
    log "Stopping service #{svc}"
    execute "stop-#{svc}" do
      command "systemctl stop #{svc}"
      returns [0,1]
      action :run
    end
  rescue => e
    Chef::Log.warn("Failed to stop #{svc}: #{e}")
  end

  def disable_service(svc)
    log "Disabling service #{svc}"
    execute "disable-#{svc}" do
      command "systemctl disable #{svc} || true"
      action :run
    end
  rescue => e
    Chef::Log.warn("Failed to disable #{svc}: #{e}")
  end

  def write_migration_log(msg)
    dir = node['migration']['log_dir']
    directory dir do
      recursive true
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end

    file "#{dir}/migration.log" do
      content "#{Time.now} - #{msg}\n"
      mode '0644'
      owner 'root'
      group 'root'
      action :create_if_missing
    end

    ruby_block "append_migration_log" do
      block do
        File.open("#{dir}/migration.log", "a") { |f| f.puts("#{Time.now} - #{msg}") }
      end
    end
  end

  def write_status(marker)
    dir = node['migration']['status_dir']
    directory dir do
      recursive true
      owner 'root'
      mode '0755'
      action :create
    end

    file "#{dir}/#{marker}" do
      content "#{Time.now} - #{marker}\n"
      mode '0644'
      owner 'root'
      action :create
    end
  end

  def migration_success(agent)
    write_migration_log("Migration to #{agent} succeeded")
    write_status('success')
  end

  def migration_failed(agent, reason=nil)
    write_migration_log("Migration to #{agent} FAILED - #{reason}")
    write_status('failed')
  end
end

# Make methods available inside recipes
Chef::Recipe.include(MigrationHelper) if defined?(Chef::Recipe)
