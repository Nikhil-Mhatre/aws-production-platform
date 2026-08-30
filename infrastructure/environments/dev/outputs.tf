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

output "vpc_endpoint_security_group_id" {
  description = "Security group ID for VPC interface endpoints"
  value       = module.vpc_endpoints.endpoint_security_group_id
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPC endpoint ID"
  value       = module.vpc_endpoints.ecr_api_endpoint_id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR Docker Registry VPC endpoint ID"
  value       = module.vpc_endpoints.ecr_dkr_endpoint_id
}

output "s3_endpoint_id" {
  description = "S3 gateway VPC endpoint ID"
  value       = module.vpc_endpoints.s3_endpoint_id
}

output "cloudwatch_logs_endpoint_id" {
  description = "CloudWatch Logs VPC endpoint ID"
  value       = module.vpc_endpoints.logs_endpoint_id
}

output "secrets_manager_endpoint_id" {
  description = "Secrets Manager VPC endpoint ID"
  value       = module.vpc_endpoints.secrets_manager_endpoint_id
}

output "ecs_log_group_name" {
  description = "CloudWatch Log Group used by ECS"
  value       = module.cloudwatch.log_group_name
}

output "ecs_log_group_arn" {
  description = "ARN of the CloudWatch Log Group used by ECS"
  value       = module.cloudwatch.log_group_arn
}

# ==============================================================================
# RDS OUTPUTS
# ==============================================================================

output "rds_instance_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_address" {
  description = "RDS PostgreSQL hostname"
  value       = module.rds.db_instance_address
}

output "rds_instance_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "LaunchPad PostgreSQL database name"
  value       = module.rds.database_name
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials"
  value       = module.rds.master_user_secret_arn
}

# ==============================================================================
# ALB OUTPUTS
# ==============================================================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.load_balancer_dns_name
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}
