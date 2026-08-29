variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones to use."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per Availability Zone."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets, one per Availability Zone."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets, one per Availability Zone."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway resources for private application subnet egress."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for all private application subnets. Recommended for lower-cost dev environments."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to VPC resources."
  type        = map(string)
  default     = {}
}
