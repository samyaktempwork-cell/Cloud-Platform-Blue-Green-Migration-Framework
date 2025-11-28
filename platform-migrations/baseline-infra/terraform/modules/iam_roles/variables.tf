variable "name_prefix" {
  description = "Prefix for IAM role and instance profile"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
