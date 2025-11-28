variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "stage_account_role_arn" {
  description = "IAM Role to assume in the STAGE account"
  type        = string
}

variable "ami_blue" {
  description = "Current AMI for blue environment"
  type        = string
}

variable "ami_green" {
  description = "New AMI for green environment"
  type        = string
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed to access ALB (stage controlled)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed SSH to app instances"
  type        = list(string)
  default     = []
}
