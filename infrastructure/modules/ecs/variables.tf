# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}


# ==============================================================================
# AWS REGION
# ==============================================================================

variable "aws_region" {
  description = "AWS region where ECS resources are deployed"
  type        = string
}


# ==============================================================================
# CONTAINER CONFIGURATION
# ==============================================================================

variable "container_name" {
  description = "Name of the application container"
  type        = string
  default     = "launchpad-api"
}

variable "container_image" {
  description = "Docker image URI used by the ECS task"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container"
  type        = number
  default     = 3000
}

variable "node_environment" {
  description = "Node.js runtime environment"
  type        = string
  default     = "production"
}


# ==============================================================================
# ECS COMPUTE
# ==============================================================================

variable "task_cpu" {
  description = "CPU units allocated to each Fargate task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MiB allocated to each Fargate task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}


# ==============================================================================
# NETWORKING
# ==============================================================================

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs where ECS tasks will run"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group assigned to ECS tasks"
  type        = string
}


# ==============================================================================
# IAM
# ==============================================================================

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}


# ==============================================================================
# CLOUDWATCH
# ==============================================================================

variable "log_group_name" {
  description = "CloudWatch Log Group used by ECS"
  type        = string
}


# ==============================================================================
# SECRETS MANAGER
# ==============================================================================

variable "database_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret"
  type        = string
  sensitive   = true
}

variable "database_host" {
  description = "Hostname of the RDS PostgreSQL instance"
  type        = string
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}


# ==============================================================================
# LOAD BALANCER
# ==============================================================================

variable "target_group_arn" {
  description = "Application Load Balancer target group ARN"
  type        = string
  default     = null
}


# ==============================================================================
# ECS DEPLOYMENT SETTINGS
# ==============================================================================

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 50
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks during deployment"
  type        = number
  default     = 200
}


# ==============================================================================
# CONTAINER INSIGHTS
# ==============================================================================

variable "enable_container_insights" {
  description = "Enable ECS Container Insights"
  type        = bool
  default     = false
}


# ==============================================================================
# COMMON TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags applied to ECS resources"
  type        = map(string)
  default     = {}
}
