variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "prod_account_role_arn" {
  type        = string
  description = "IAM role to assume in PROD account"
}

variable "ami_blue" {
  type        = string
  description = "AMI for BLUE ASG"
}

variable "ami_green" {
  type        = string
  description = "AMI for GREEN ASG"
}

variable "allowed_http_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/16"]  # PRODUCTION restriction
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}
