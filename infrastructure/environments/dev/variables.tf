variable "aws_region" {
  description = "AWS region for the development environment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in resource naming and tags."
  type        = string
  default     = "aws-production-platform"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "This root module is intended for the dev environment."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the development VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway. Disabled for the networking-only milestone to avoid unnecessary cost."
  type        = bool
  default     = false
}
