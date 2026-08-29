# ==============================================================================
# SECURITY GROUP
# ==============================================================================

output "endpoint_security_group_id" {
  description = "Security group ID used by the VPC interface endpoints"
  value       = aws_security_group.endpoints.id
}


# ==============================================================================
# ECR ENDPOINTS
# ==============================================================================

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR Docker Registry VPC endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}


# ==============================================================================
# S3 ENDPOINT
# ==============================================================================

output "s3_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}


# ==============================================================================
# CLOUDWATCH LOGS ENDPOINT
# ==============================================================================

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = aws_vpc_endpoint.logs.id
}


# ==============================================================================
# SECRETS MANAGER ENDPOINT
# ==============================================================================

output "secrets_manager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = aws_vpc_endpoint.secrets_manager.id
}
