variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "shared_services_role_arn" {
  type        = string
  description = "IAM role for Terraform in shared-services account"
}
