# variables.tf - inputs for the migration wrapper

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "env" {
  description = "environment (dev|stage|prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  type    = string
  default = "migration-rapid7-qualys"
}

variable "chef_role" {
  type    = string
  default = "rapid7_to_qualys"
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "qualys_activation_id" {
  type    = string
  default = ""
  description = "Qualys Activation ID (prefer secrets/SSM in prod)"
}

variable "qualys_customer_id" {
  type    = string
  default = ""
  description = "Qualys Customer ID (prefer secrets/SSM in prod)"
}

variable "tags" {
  type = map(string)
  default = {}
}
