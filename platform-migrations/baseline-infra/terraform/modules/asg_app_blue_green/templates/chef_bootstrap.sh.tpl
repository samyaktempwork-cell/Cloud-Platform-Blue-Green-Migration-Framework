#!/bin/bash
set -xe

# -----------------------------------------------------------------------------
# User-data startup script for Chef integration
# -----------------------------------------------------------------------------

ROLE_NAME="${chef_role}"
LOG_FILE="/var/log/chef_bootstrap.log"

echo "Starting Chef bootstrap for role: $ROLE_NAME" | tee -a $LOG_FILE

# Ensure Chef paths exist (AMI ALREADY HAS COOKBOOKS)
mkdir -p /etc/chef
mkdir -p /var/chef/cache
mkdir -p /var/log/chef

cat <<EOF >/etc/chef/client.rb
cookbook_path "/var/chef/cookbooks"
role_path "/var/chef/roles"
file_cache_path "/var/chef/cache"
log_level :info
EOF

# Write first-boot JSON
cat <<EOF >/etc/chef/first-boot.json
{
  "run_list": [
    "role[$ROLE_NAME]"
  ]
}
EOF

echo "Running initial chef-client..." | tee -a $LOG_FILE
chef-client -z -j /etc/chef/first-boot.json | tee -a $LOG_FILE

# -----------------------------------------------------------------------------
# Create systemd timer for automated chef-client runs
# -----------------------------------------------------------------------------

cat <<'EOF' >/etc/systemd/system/chef-client.service
[Unit]
Description=Run Chef Client

[Service]
Type=simple
ExecStart=/usr/bin/chef-client -z
EOF

cat <<'EOF' >/etc/systemd/system/chef-client.timer
[Unit]
Description=Run Chef Client every 30 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now chef-client.timer

echo "Chef bootstrap completed." | tee -a $LOG_FILE
