# -----------------------------------------------------------------------------
# Stage Provider with AssumeRole
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.stage_account_role_arn
    session_name = "terraform-stage-session"
  }
}

locals {
  tags = {
    Environment = "stage"
    Project     = "CloudPlatform-Migrations"
    Owner       = "PlatformTeam"
  }
}

# -----------------------------------------------------------------------------
# VPC 
# -----------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name       = "stage-main"
  cidr_block = "10.20.0.0/16"    # STAGE CIDR RANGE
  az_count   = 3
  tags       = local.tags
}

# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------

module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id             = module.vpc.vpc_id
  allowed_http_cidrs = var.allowed_http_cidrs
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  tags               = local.tags
}

# -----------------------------------------------------------------------------
# IAM Roles for EC2 Instances
# -----------------------------------------------------------------------------

module "iam_roles" {
  source = "../../modules/iam_roles"

  name_prefix = "stage-app"
  tags        = local.tags
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  name_prefix       = "stage-app"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  tags              = local.tags
}

# -----------------------------------------------------------------------------
# ASG Blue/Green Setup
# -----------------------------------------------------------------------------

module "asg" {
  source = "../../modules/asg_app_blue_green"

  app_name              = "stage-app"
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_sg_id

  ami_blue  = var.ami_blue
  ami_green = var.ami_green

  instance_type = "t3.small"

  target_group_blue_arn  = module.alb.target_group_blue_arn
  target_group_green_arn = module.alb.target_group_green_arn

  desired_capacity_blue  = 2
  desired_capacity_green = 0   # Stage Green inactive by default

  min_size = 1
  max_size = 4

  tags = local.tags
}
