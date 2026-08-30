# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or prod"
  type        = string
}


# ==============================================================================
# NETWORKING
# ==============================================================================
variable "vpc_id" {
  description = "ID of the VPC where the endpoints will be created"
  type        = string
}


variable "public_subnet_ids" {
  description = "Public subnet IDs where the internet-facing ALB will be deployed"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID assigned to the Application Load Balancer"
  type        = string
}


# ==============================================================================
# APPLICATION
# ==============================================================================

variable "target_port" {
  description = "Port exposed by the LaunchPad API ECS container"
  type        = number
  default     = 3000
}


# ==============================================================================
# COMMON TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags applied to ALB resources"
  type        = map(string)
  default     = {}
}
