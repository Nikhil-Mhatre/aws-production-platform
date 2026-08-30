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

variable "log_retention_days" {
  description = "Number of days CloudWatch Logs should be retained"
  type        = number

  validation {
    condition = contains(
      [
        1,
        3,
        5,
        7,
        14,
        30,
        60,
        90,
        120,
        150,
        180,
        365,
        400,
        545,
        731,
        1096,
        1827,
        2192,
        2557,
        2922,
        3288,
        3653,
        0
      ],
      var.log_retention_days
    )

    error_message = "log_retention_days must be a valid CloudWatch Logs retention value."
  }
}
