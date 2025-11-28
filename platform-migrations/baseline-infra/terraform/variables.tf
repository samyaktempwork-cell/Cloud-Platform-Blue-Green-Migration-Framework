variable "env_name" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "role_arn" {
  description = "AssumeRole ARN per environment"
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR block per environment"
  type        = string
}

variable "ami_blue" {
  description = "AMI used for the BLUE ASG"
  type        = string
}

variable "ami_green" {
  description = "AMI used for the GREEN ASG"
  type        = string
}

variable "allowed_http_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = []
}

variable "desired_capacity_blue" {
  type    = number
  default = 2
}

variable "desired_capacity_green" {
  type    = number
  default = 0
}
