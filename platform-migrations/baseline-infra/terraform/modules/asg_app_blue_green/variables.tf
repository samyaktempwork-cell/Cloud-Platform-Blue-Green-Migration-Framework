variable "app_name" {
  description = "Application name prefix"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASGs"
  type        = list(string)
}

variable "ami_blue" {
  description = "AMI ID for current (blue) environment"
  type        = string
}

variable "ami_green" {
  description = "AMI ID for new (green) environment"
  type        = string
}

variable "instance_type" {
  description = "Instance type for ASG"
  type        = string
  default     = "t3.small"
}

variable "app_security_group_id" {
  description = "Security group ID to attach to instances"
  type        = string
}

variable "target_group_blue_arn" {
  description = "Target group ARN for blue ASG"
  type        = string
}

variable "target_group_green_arn" {
  description = "Target group ARN for green ASG"
  type        = string
}

variable "desired_capacity_blue" {
  description = "Desired capacity for blue ASG"
  type        = number
  default     = 2
}

variable "desired_capacity_green" {
  description = "Desired capacity for green ASG"
  type        = number
  default     = 0
}

variable "min_size" {
  description = "Min size for both ASGs"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Max size for both ASGs"
  type        = number
  default     = 4
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "chef_role" {
  description = "Chef role applied to instances in this ASG"
  type        = string
}