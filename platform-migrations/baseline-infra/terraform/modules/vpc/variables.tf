variable "name" {
  description = "Name prefix for VPC and subnets"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to spread subnets across"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}
