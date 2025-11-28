provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.shared_services_role_arn
    session_name = "terraform-shared-services"
  }
}

locals {
  tags = {
    Environment = "shared-services"
    Project     = "CloudPlatform-Migrations"
    Owner       = "PlatformTeam"
  }
}

resource "aws_iam_role" "dummy_placeholder" {
  name = "shared-services-placeholder"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}
