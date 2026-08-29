output "vpc_id" {
  description = "Development VPC ID."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Development VPC CIDR."
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Development public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Development private application subnet IDs."
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Development private database subnet IDs."
  value       = module.vpc.private_db_subnet_ids
}

output "nat_gateway_ids" {
  description = "Development NAT Gateway IDs, if enabled."
  value       = module.vpc.nat_gateway_ids
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS Fargate tasks"
  value       = module.security_groups.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS PostgreSQL"
  value       = module.security_groups.rds_security_group_id
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.iam.ecs_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = module.iam.ecs_task_role_arn
}
