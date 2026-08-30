variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository ECS is allowed to pull from"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group used by ECS"
  type        = string
}
