directory node['migration_common']['dir'] do
  owner 'root'
  mode '0755'
end

file node['migration_common']['status_file'] do
  content "Migration layer initialized at #{Time.now}"
  mode '0644'
end
