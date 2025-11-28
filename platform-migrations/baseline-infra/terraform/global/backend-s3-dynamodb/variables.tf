variable "aws_region" {
  description = "AWS region for TF backend"
  type        = string
  default     = "ap-south-1"
}

variable "backend_bucket" {
  description = "Name of S3 bucket for Terraform remote state"
  type        = string
}

variable "lock_table" {
  description = "DynamoDB table for state locking"
  type        = string
  default     = "tf-state-locks"
}

variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    Project = "CloudPlatform-Migrations"
    Owner   = "PlatformTeam"
  }
}
