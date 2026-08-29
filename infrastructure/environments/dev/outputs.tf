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
