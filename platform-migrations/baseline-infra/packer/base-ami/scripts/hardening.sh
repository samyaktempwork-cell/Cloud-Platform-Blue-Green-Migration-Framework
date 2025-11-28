#!/bin/bash
set -e

echo "Applying baseline hardening..."

# Disable password authentication (optional)
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || true

# Ensure yum/dnf updates are applied
sudo dnf update -y

# Remove unwanted packages
sudo dnf remove -y telnet rsh ypbind || true

# Ensure auditd is running
sudo systemctl enable auditd
sudo systemctl start auditd

echo "Baseline hardening applied."
