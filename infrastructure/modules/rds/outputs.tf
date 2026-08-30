# ==============================================================================
# RDS INSTANCE
# ==============================================================================

output "db_instance_id" {
  description = "RDS database instance identifier"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the RDS database instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "RDS PostgreSQL hostname"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Initial PostgreSQL database name"
  value       = aws_db_instance.this.db_name
}


# ==============================================================================
# DB SUBNET GROUP
# ==============================================================================

output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.this.name
}


# ==============================================================================
# SECRETS MANAGER
# ==============================================================================
# RDS manages the master password through Secrets Manager.
#
# We expose only the ARN, not the actual secret value.
# ==============================================================================

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS master credentials"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
