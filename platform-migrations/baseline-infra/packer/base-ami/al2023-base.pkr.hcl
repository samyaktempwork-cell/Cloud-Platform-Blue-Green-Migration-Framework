packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "aws_region" {
  default = "ap-south-1"
}

source "amazon-ebs" "al2023" {
  region = var.aws_region
  instance_type = "t3.small"
  ssh_username  = "ec2-user"

  ami_name = "al2023-base-chef-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  name    = "al2023-base-chef"
  sources = ["source.amazon-ebs.al2023"]

  provisioner "shell" {
    script = "scripts/install_chef.sh"
  }

  provisioner "shell" {
    script = "scripts/hardening.sh"
  }
}
