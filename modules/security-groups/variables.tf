# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS MODULE VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for security group names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
