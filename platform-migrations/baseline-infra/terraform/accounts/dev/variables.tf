variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "dev_account_role_arn" {
  description = "IAM role to assume in the DEV account for Terraform"
  type        = string
}

variable "ami_blue" {
  description = "Current production AMI for blue ASG"
  type        = string
}

variable "ami_green" {
  description = "New AMI for green deployment"
  type        = string
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed to hit ALB (default to all)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed SSH to app instances"
  type        = list(string)
  default     = []
}
