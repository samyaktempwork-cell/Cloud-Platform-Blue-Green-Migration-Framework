#
# logging.rb
# Ensure migration logging directories, rotation, and helper script are present.
#

# Attributes (fall back to defaults if not defined)
log_dir = node.fetch('migration', {})['log_dir'] || '/opt/migration/logs'
status_dir = node.fetch('migration', {})['status_dir'] || '/opt/migration/status'
collector_dir = '/opt/migration/bin'
logrotate_path = '/etc/logrotate.d/migration'

# Create directories with correct ownership/mode
[ log_dir, status_dir, collector_dir ].each do |d|
  directory d do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end
end

# Place the collect_logs helper
cookbook_file "#{collector_dir}/collect_logs.sh" do
  source 'collect_logs.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Place logrotate template
template logrotate_path do
  source 'logrotate_migration.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    log_dir: log_dir,
    rotate_count: node.fetch('migration', {})['rotate_count'] || 7,
    rotate_size: node.fetch('migration', {})['rotate_size'] || '50M'
  )
  action :create
end

# Add optional systemd timer to run collect_logs periodically (every 6 hours)
systemd_unit 'collect-logs.service' do
  content({
    Unit: {
      Description: 'Collect migration logs (helper)',
    },
    Service: {
      Type: 'oneshot',
      ExecStart: "#{collector_dir}/collect_logs.sh --upload || true",
      User: 'root'
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  })
  action [:create, :enable]
end

systemd_unit 'collect-logs.timer' do
  content({
    Unit: {
      Description: 'Run collect-logs every 6 hours'
    },
    Timer: {
      OnCalendar: '*-*-* *:00/6:00',
      Persistent: 'true'
    },
    Install: {
      WantedBy: 'timers.target'
    }
  })
  action [:create, :enable, :start]
end

# Ensure migration.log exists and has proper perms
file "#{log_dir}/migration.log" do
  owner 'root'
  group 'root'
  mode '0644'
  content "#{Time.now.utc} - migration log initialized\n"
  action :create_if_missing
end

# Ensure status dir has a README (.gitignore-style human hint)
file "#{status_dir}/README" do
  owner 'root'
  group 'root'
  mode '0644'
  content <<~TXT
    Directory: #{status_dir}
    Files here indicate migration status. Each JSON file follows the schema defined in README-logging.md
  TXT
  action :create_if_missing
end

# Provide Chef logging entry
ruby_block 'write-migration-log-start' do
  block do
    begin
      File.open("#{log_dir}/migration.log","a") { |f| f.puts("#{Time.now.utc} - logging configured by Chef") }
    rescue => e
      Chef::Log.warn("Unable to append migration log: #{e}")
    end
  end
  action :run
end
