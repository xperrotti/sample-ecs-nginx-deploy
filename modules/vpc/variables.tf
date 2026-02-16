# ---------------------------------------------------------------------------------------------------------------------
# VPC MODULE VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for all VPC resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to deploy across"
  type        = list(string)
}

variable "subnet_newbits" {
  description = "Number of bits to add for subnet CIDR calculation (e.g., 8 = /24 subnets for a /16 VPC)"
  type        = number
  default     = 8
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
