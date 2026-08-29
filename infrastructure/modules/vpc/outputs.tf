# ==============================================================================
# VPC OUTPUTS
# These outputs provide the foundational details of the created network.
# ==============================================================================

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
  # Example usage: If you need to create a Security Group in another module or file,
  # you will need to reference this vpc_id to tell AWS where to place it[cite: 2].
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
  # Useful if you need to set up VPC Peering or configure security group rules
  # that allow internal traffic across the entire VPC[cite: 2].
}

# ==============================================================================
# SUBNET OUTPUTS
# ==============================================================================

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
  # Note for juniors: The '[*]' is called a 'splat expression'.
  # Because we used 'count' in main.tf to create multiple subnets, aws_subnet.public
  # is actually a list of resources. The splat expression cleanly extracts just
  # the 'id' attribute from every subnet in that list[cite: 2].
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = aws_subnet.private_app[*].id
  # You would typically pass this list of IDs to an Auto Scaling Group, EKS Node Group,
  # or ECS cluster to ensure your application servers deploy into the private tier[cite: 2].
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = aws_subnet.private_db[*].id
  # You would pass this list to an AWS RDS Subnet Group so your databases are
  # provisioned safely in the isolated database tier[cite: 2].
}

# ==============================================================================
# GATEWAY OUTPUTS
# ==============================================================================

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways, if enabled."
  value       = aws_nat_gateway.this[*].id
  # If the user sets 'enable_nat_gateway = false' in variables, Terraform won't create any,
  # and this output will gracefully return an empty list[cite: 2].
}
