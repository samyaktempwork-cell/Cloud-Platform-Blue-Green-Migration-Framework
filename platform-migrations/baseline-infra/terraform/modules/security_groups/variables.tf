variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to access HTTP on ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into app instances"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
