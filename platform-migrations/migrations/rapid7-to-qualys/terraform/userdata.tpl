#!/bin/bash
# userdata.tpl - executed by EC2 instances at first boot
# Variables injected by Terraform:
#   ${env}, ${chef_role}, ${activation_id}, ${customer_id}, ${migration_module}

set -xe

LOG_DIR="/opt/migration/logs"
STATUS_DIR="/opt/migration/status"
MODULE="${migration_module}"
ENV="${env}"
CHEF_ROLE="${chef_role}"
ACTIVATION_ID="${activation_id}"
CUSTOMER_ID="${customer_id}"

mkdir -p ${LOG_DIR}
mkdir -p ${STATUS_DIR}
touch ${LOG_DIR}/migration.log

echo "[BOOTSTRAP] Starting migration userdata for ${MODULE} (env=${ENV})" | tee -a ${LOG_DIR}/migration.log
date --iso-8601=seconds >> ${LOG_DIR}/migration.log

# -------------------------------
# 1) Minimal prerequisites (safe)
# -------------------------------
# Note: AMI should ideally already have Chef & dependencies baked-in.
# Keep runtime changes minimal to reduce drift.
if ! command -v chef-client >/dev/null 2>&1; then
  echo "[BOOTSTRAP] chef-client not found, installing via Omnitruck (this may vary by distro)" | tee -a ${LOG_DIR}/migration.log
  curl -sSL https://omnitruck.chef.io/install.sh | bash || {
    echo "[BOOTSTRAP] Chef install failed - continuing in best-effort mode" | tee -a ${LOG_DIR}/migration.log
  }
fi

# -------------------------------------
# 2) Write chef client.rb and first-boot
# -------------------------------------
cat > /etc/chef/client.rb <<'EOF'
log_level        :info
log_location     '/opt/migration/logs/chef-client.log'
local_mode       true
chef_zero.enabled true
cookbook_path    ['/var/chef/cookbooks']
role_path        ['/var/chef/roles']
file_cache_path  '/var/chef/cache'
EOF

cat > /etc/chef/first-boot.json <<EOF
{
  "run_list": ["role[${CHEF_ROLE}]"],
  "qualys": {
    "activation_id": "${ACTIVATION_ID}",
    "customer_id": "${CUSTOMER_ID}"
  },
  "migration": {
    "module": "${MODULE}",
    "env": "${ENV}"
  }
}
EOF

# -------------------------------------
# 3) Run Chef in local mode
# -------------------------------------
echo "[BOOTSTRAP] Running chef-client -z -j /etc/chef/first-boot.json" | tee -a ${LOG_DIR}/migration.log
chef-client -z -j /etc/chef/first-boot.json 2>&1 | tee -a ${LOG_DIR}/migration.log
CHEF_EXIT=${PIPESTATUS[0]}

# -------------------------------------
# 4) Write status file
# -------------------------------------
STATUS_FILE="${STATUS_DIR}/${MODULE}.json"

if [ "${CHEF_EXIT}" -eq 0 ]; then
  cat > ${STATUS_FILE} <<EOF
{
  "module": "${MODULE}",
  "env": "${ENV}",
  "timestamp": "$(date --iso-8601=seconds)",
  "status": "success"
}
EOF
  echo "[BOOTSTRAP] Chef completed successfully for ${MODULE}" | tee -a ${LOG_DIR}/migration.log
else
  cat > ${STATUS_FILE} <<EOF
{
  "module": "${MODULE}",
  "env": "${ENV}",
  "timestamp": "$(date --iso-8601=seconds)",
  "status": "failed",
  "chef_exit_code": "${CHEF_EXIT}"
}
EOF
  echo "[BOOTSTRAP] Chef failed for ${MODULE} (exit=${CHEF_EXIT})" | tee -a ${LOG_DIR}/migration.log
fi

echo "[BOOTSTRAP] userdata finished" | tee -a ${LOG_DIR}/migration.log
