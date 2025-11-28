# SSM agent
default['bootstrap']['ssm']['enabled'] = true
default['bootstrap']['ssm']['package'] = 'amazon-ssm-agent'
default['bootstrap']['ssm']['service'] = 'amazon-ssm-agent'

# Platform user
default['bootstrap']['platform_user']['name'] = 'platform'
default['bootstrap']['platform_user']['shell'] = '/bin/bash'
default['bootstrap']['platform_user']['home'] = '/opt/platform'

# Directories
default['bootstrap']['directories'] = [
  '/opt/platform',
  '/var/log/platform'
]

# Bootstrap status file
default['bootstrap']['status_file'] = '/opt/platform/bootstrap_complete'
