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
# AWS REGION
# ==============================================================================

variable "aws_region" {
  description = "AWS region where the VPC endpoints will be created"
  type        = string
}


# ==============================================================================
# VPC
# ==============================================================================

variable "vpc_id" {
  description = "ID of the VPC where the endpoints will be created"
  type        = string
}


# ==============================================================================
# PRIVATE APPLICATION SUBNETS
# ==============================================================================

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs where interface endpoints will be created"
  type        = list(string)
}


# ==============================================================================
# PRIVATE APPLICATION ROUTE TABLES
# ==============================================================================

variable "private_app_route_table_ids" {
  description = "Private application route table IDs used by gateway endpoints"
  type        = list(string)
}


# ==============================================================================
# ECS SECURITY GROUP
# ==============================================================================

variable "ecs_security_group_id" {
  description = "Security group ID assigned to ECS Fargate tasks"
  type        = string
}


# ==============================================================================
# COMMON TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags applied to VPC endpoint resources"
  type        = map(string)
  default     = {}
}
