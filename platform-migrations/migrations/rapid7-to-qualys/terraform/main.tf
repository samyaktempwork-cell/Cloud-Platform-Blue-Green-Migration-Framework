# main.tf - Migration wrapper that calls baseline ASG module and injects userdata

terraform {
  required_version = ">= 1.6.0"
}

# Provider configured here; consider moving provider config to repo-level or CI inputs
provider "aws" {
  region = var.aws_region
}

# Render userdata from template
data "templatefile" "userdata" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    env              = var.env
    chef_role        = var.chef_role
    activation_id    = var.qualys_activation_id
    customer_id      = var.qualys_customer_id
    migration_module = "rapid7_to_qualys"
  }
}

# Use baseline ASG module (adjust relative path based on your repo layout)
module "migration_asg" {
  source = "../../../../baseline-infra/terraform/modules/asg_app_blue_green"

  app_name       = var.app_name
  ami_id         = var.ami_id
  instance_type  = var.instance_type

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  security_group_ids = var.security_group_ids

  # inject user_data - base64 encoded as Launch Template expects
  user_data = base64encode(data.templatefile.userdata.rendered)

  # If your ASG module supports IAM instance profile or instance_profile_name,
  # pass the instance profile name. Adjust keys as per module interface.
  instance_profile = aws_iam_instance_profile.migration_profile.name
  tags = var.tags
}

# IAM Role & Policy for migration instances (runtime role)
resource "aws_iam_role" "migration_runtime_role" {
  name_prefix = "${var.app_name}-runtime-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "migration_runtime_policy" {
  name = "${var.app_name}-runtime-policy"
  role = aws_iam_role.migration_runtime_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ],
        Resource = "*"
      },
      {
        Sid = "S3ReadIfUsed",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },
      {
        Sid = "SSMReadIfUsed",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      },
      {
        Sid = "EC2Describe",
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeInstanceStatus"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "migration_profile" {
  name = "${var.app_name}-instance-profile"
  role = aws_iam_role.migration_runtime_role.name
}

# Optional: CloudWatch log group for migration logs (useful if you push logs)
resource "aws_cloudwatch_log_group" "migration_logs" {
  name              = "/migration/${var.app_name}"
  retention_in_days = 14
  depends_on        = [aws_iam_role_policy.migration_runtime_policy]
}

# Simple outputs
output "asg_name" {
  value = module.migration_asg.asg_name
}

output "instance_profile" {
  value = aws_iam_instance_profile.migration_profile.name
}
