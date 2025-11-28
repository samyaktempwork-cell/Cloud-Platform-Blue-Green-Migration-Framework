locals {
  tags = {
    Environment = var.env_name
    Project     = "CloudPlatform-Migrations"
    Owner       = "PlatformTeam"
  }
}

# -----------------------------------------------------
# AWS Provider (assume-role per environment)
# -----------------------------------------------------
provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.role_arn
    session_name = "terraform-${var.env_name}-session"
  }
}

# -----------------------------------------------------
# VPC
# -----------------------------------------------------
module "vpc" {
  source     = "./modules/vpc"
  name       = "${var.env_name}-main"
  cidr_block = var.cidr_block
  az_count   = 3
  tags       = local.tags
}

# -----------------------------------------------------
# Security Groups
# -----------------------------------------------------
module "security_groups" {
  source             = "./modules/security_groups"
  vpc_id             = module.vpc.vpc_id
  allowed_http_cidrs = var.allowed_http_cidrs
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  tags               = local.tags
}

# -----------------------------------------------------
# IAM Roles
# -----------------------------------------------------
module "iam_roles" {
  source      = "./modules/iam_roles"
  name_prefix = "${var.env_name}-app"
  tags        = local.tags
}

# -----------------------------------------------------
# ALB
# -----------------------------------------------------
module "alb" {
  source             = "./modules/alb"
  name_prefix        = "${var.env_name}-app"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.alb_sg_id
  tags               = local.tags
}

# -----------------------------------------------------
# ASG BLUE/GREEN
# -----------------------------------------------------
module "asg" {
  source = "./modules/asg_app_blue_green"

  app_name              = "${var.env_name}-app"
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_sg_id

  ami_blue  = var.ami_blue
  ami_green = var.ami_green

  instance_type = "t3.small"

  target_group_blue_arn  = module.alb.target_group_blue_arn
  target_group_green_arn = module.alb.target_group_green_arn

  desired_capacity_blue  = var.desired_capacity_blue
  desired_capacity_green = var.desired_capacity_green

  min_size = 1
  max_size = 4

  tags = local.tags
}
