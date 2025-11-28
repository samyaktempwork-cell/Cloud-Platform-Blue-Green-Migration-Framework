#!/bin/bash
set -e

echo "Installing SSM Agent..."

sudo dnf install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "SSM Agent installed successfully."
