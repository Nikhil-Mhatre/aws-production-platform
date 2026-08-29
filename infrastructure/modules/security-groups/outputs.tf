# ==============================================================================
# SECURITY GROUP OUTPUTS
# Outputs are like the "return values" of this module. When AWS creates these
# security groups, it assigns them unique, random IDs (e.g., sg-0123456...).
# We output them here so other Terraform modules can reference them!
# ==============================================================================

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
  # How to use: You will pass this ID into your Load Balancer module to ensure
  # the ALB actually applies the public-facing rules we defined in main.tf.
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS Fargate tasks"
  value       = aws_security_group.ecs.id
  # How to use: You will pass this ID into your ECS module's network configuration
  # so your application containers are protected by this specific security group.
}

output "rds_security_group_id" {
  description = "Security group ID for RDS PostgreSQL"
  value       = aws_security_group.rds.id
  # How to use: You will pass this ID to your Database module to attach these strict,
  # internal-only access rules directly to your RDS database instance.
}
