default['rapid7']['package_name'] = 'insight-agent'
default['rapid7']['service_name'] = 'ir_agent'
default['rapid7']['config_path']  = '/opt/rapid7/ir_agent'
default['rapid7']['log_path']     = '/opt/migration/logs/rapid7'
default['rapid7']['uninstall_script'] = '/opt/rapid7/ir_agent/components/agentControl'

#
# Qualys settings (loaded from data_bags at runtime)
#
default['qualys']['package_url'] = nil   # populated from data_bag
default['qualys']['activation_id'] = nil # populated from data_bag
default['qualys']['customer_id'] = nil   # populated from data_bag
default['qualys']['service_name'] = 'qualys-cloud-agent'
default['qualys']['install_dir']  = '/opt/qualys'
default['qualys']['log_path']     = '/opt/migration/logs/qualys'

#
# Common Migration Settings
#
default['migration']['log_dir']        = '/opt/migration/logs'
default['migration']['status_dir']     = '/opt/migration/status'
default['migration']['rollback_enabled'] = true
default['migration']['validate_qualys'] = true
default['migration']['validate_delay']  = 25  # seconds to wait for Qualys heartbeat
