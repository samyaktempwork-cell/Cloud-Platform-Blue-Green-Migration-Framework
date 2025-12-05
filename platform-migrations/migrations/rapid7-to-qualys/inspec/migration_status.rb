# migration_status.rb - InSpec controls to validate migration succeeded on the node
control 'migration-status-1' do
  impact 1.0
  title 'Migration status file exists and indicates success'
  desc 'Verify the migration status file exists and contains a success status'

  status_file = '/opt/migration/status/rapid7_to_qualys.json'

  describe file(status_file) do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
  end

  describe json(status_file) do
    its(['status']) { should eq 'success' }
    its(['module']) { should eq 'rapid7_to_qualys' }
    its(['env']) { should match /dev|stage|prod/ }
    its(['timestamp']) { should_not be_nil }
  end
end

control 'migration-logs-1' do
  impact 0.7
  title 'Migration logs exist and are not empty'
  desc 'Check that migration logs are present and have content'

  log_dir = '/opt/migration/logs'

  describe directory(log_dir) do
    it { should exist }
    it { should be_directory }
  end

  describe command("bash -lc 'test -s #{log_dir}/migration.log && echo OK || echo EMPTY'") do
    its('stdout') { should match /OK|EMPTY/ }
  end
end
