# System update
default['base_hardening']['system_update'] = true

# SSH hardening
default['base_hardening']['ssh']['permit_root_login'] = 'no'
default['base_hardening']['ssh']['password_auth'] = 'no'

# Auditd
default['base_hardening']['auditd']['enabled'] = true

# Packages to remove
default['base_hardening']['packages']['remove'] = %w(
  telnet
  rsh
  ypbind
)

# Additional secured sysctl values (optional future hardening)
default['base_hardening']['sysctl'] = {
  'net.ipv4.icmp_echo_ignore_broadcasts' => 1,
  'net.ipv4.conf.all.accept_redirects' => 0
}
