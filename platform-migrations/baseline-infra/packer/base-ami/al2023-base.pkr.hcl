packer {
  required_version = ">= 1.9.0"

  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "ami_prefix" {
  type    = string
  default = "al2023-base-chef"
}

# -------------------------------------------------------------------
# Source Image (Amazon Linux 2023)
# -------------------------------------------------------------------
source "amazon-ebs" "al2023" {
  region        = var.aws_region
  instance_type = "t3.small"
  ssh_username  = "ec2-user"

  ami_name = "${var.ami_prefix}-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  tags = {
    "Project"     = "CloudPlatform-Migrations"
    "Image-Type"  = "Base"
    "OS"          = "AmazonLinux2023"
    "Security"    = "Chef-Hardened"
  }
}

# -------------------------------------------------------------------
# Build Section
# -------------------------------------------------------------------
build {
  name    = "al2023-base-chef"
  sources = ["source.amazon-ebs.al2023"]

  # ------------------------------
  # Install AWS SSM Agent
  # ------------------------------
  provisioner "shell" {
    script = "scripts/install_ssm.sh"
  }

  # ------------------------------
  # Install Chef Client
  # ------------------------------
  provisioner "shell" {
    script = "scripts/install_chef.sh"
  }

  # ------------------------------
  # Base hardening & OS updates (fallback)
  # ------------------------------
  provisioner "shell" {
    script = "scripts/hardening.sh"
  }

  # ------------------------------
  # Upload Chef cookbooks + roles
  # ------------------------------
  provisioner "file" {
    source      = "../../chef/cookbooks"
    destination = "/tmp/chef/cookbooks"
  }

  provisioner "file" {
    source      = "../../chef/roles"
    destination = "/tmp/chef/roles"
  }

  # ------------------------------
  # Configure Chef client directory layout
  # ------------------------------
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/chef",
      "sudo mkdir -p /var/chef/cache",
      "sudo cp -r /tmp/chef/cookbooks /var/chef/",
      "sudo cp -r /tmp/chef/roles /var/chef/",
      "sudo bash -c 'cat > /etc/chef/client.rb <<EOF
cookbook_path \"/var/chef/cookbooks\"
role_path \"/var/chef/roles\"
file_cache_path \"/var/chef/cache\"
log_level :info
EOF'"
    ]
  }

  # ------------------------------
  # Run Chef Hardening (Role: base)
  # ------------------------------
  provisioner "shell" {
    inline = [
      "sudo chef-client -z -o 'role[base]'"
    ]
  }

  # ------------------------------
  # Run Bootstrap (Role: app_node)
  # ------------------------------
  provisioner "shell" {
    inline = [
      "sudo chef-client -z -o 'role[app_node]'"
    ]
  }

  # ------------------------------
  # Validate Chef output + system readiness
  # ------------------------------
  provisioner "shell" {
    inline = [
      "echo 'Validating Chef provisioning...'",
      "sudo test -d /var/chef/cookbooks/base_hardening",
      "sudo test -d /var/chef/cookbooks/bootstrap",
      "sudo test -f /opt/platform/bootstrap_complete",
      "sudo systemctl status amazon-ssm-agent | grep Active"
    ]
  }

  # ------------------------------
  # Cleanup unused packages (optional)
  # ------------------------------
  provisioner "shell" {
    inline = [
      "sudo dnf clean all",
      "sudo rm -rf /tmp/chef"
    ]
  }

}
