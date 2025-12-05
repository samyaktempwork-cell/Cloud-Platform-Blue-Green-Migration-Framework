#
# remove_rapid7.rb
# Enterprise-grade Rapid7 uninstall logic
#

write_migration_log("Starting Rapid7 removal")

pkg = node['rapid7']['package_name']
svc = node['rapid7']['service_name']
cfg = node['rapid7']['config_path']
uninst = node['rapid7']['uninstall_script']

if pkg_installed?(pkg)
  write_migration_log("Rapid7 detected: #{pkg}")

  # Stop and disable service
  stop_service(svc)
  disable_service(svc)

  # Run vendor uninstall script if present
  if ::File.exist?(uninst)
    write_migration_log("Running vendor uninstall script #{uninst}")
    execute "rapid7-vendor-uninstall" do
      command "#{uninst} uninstall || true"
      live_stream true
      returns [0,1]
      action :run
    end
  else
    write_migration_log("Vendor uninstall script not found, continuing with RPM removal")
  end

  # Remove RPM (best effort)
  execute "remove-rapid7-rpm" do
    command "rpm -e #{pkg} || true"
    action :run
  end

  # Cleanup config directory
  directory cfg do
    action :delete
    recursive true
    ignore_failure true
  end

  write_migration_log("Rapid7 removal completed")
else
  write_migration_log("Rapid7 not installed; skipping removal")
end
