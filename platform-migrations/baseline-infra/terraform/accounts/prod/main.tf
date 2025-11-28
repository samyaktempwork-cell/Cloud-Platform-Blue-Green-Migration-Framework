# -----------------------------------------------------------------------------
# AWS Provider (Assume Role into PROD)
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.prod_account_role_arn
    session_name = "terraform-prod-session"
  }
}

locals {
  tags = {
    Environment = "prod"
    Project     = "CloudPlatform-Migrations"
    Owner       = "PlatformTeam"
  }
}

# -----------------------------------------------------------------------------
# VPC Setup
# -----------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name       = "prod-main"
  cidr_block = "10.30.0.0/16"
  az_count   = 3

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------

module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id             = module.vpc.vpc_id
  allowed_http_cidrs = var.allowed_http_cidrs
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs

  tags = local.tags
}

# -----------------------------------------------------------------------------
# IAM EC2 Roles
# -----------------------------------------------------------------------------

module "iam_roles" {
  source      = "../../modules/iam_roles"
  name_prefix = "prod-app"
  tags        = local.tags
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

module "alb" {
  source            = "../../modules/alb"
  name_prefix       = "prod-app"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  tags              = local.tags
}

# -----------------------------------------------------------------------------
# Autoscaling Group Blue/Green
# -----------------------------------------------------------------------------

module "asg" {
  source = "../../modules/asg_app_blue_green"

  app_name              = "prod-app"
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_sg_id

  ami_blue              = var.ami_blue
  ami_green             = var.ami_green

  desired_capacity_blue  = 3
  desired_capacity_green = 0

  min_size = 2
  max_size = 6

  target_group_blue_arn  = module.alb.target_group_blue_arn
  target_group_green_arn = module.alb.target_group_green_arn

  tags = local.tags
}
