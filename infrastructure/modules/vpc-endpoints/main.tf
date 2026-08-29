# ==============================================================================
# VPC ENDPOINTS
# ==============================================================================
# This module provides private connectivity from resources in private
# application subnets to selected AWS services.
#
# Interface endpoints:
#   - ECR API
#   - ECR Docker Registry
#   - CloudWatch Logs
#   - Secrets Manager
#
# Gateway endpoint:
#   - S3
#
# This reduces unnecessary dependency on the NAT Gateway for AWS service
# traffic and keeps supported AWS-service communication inside the AWS network.
# ==============================================================================


# ==============================================================================
# SECURITY GROUP FOR INTERFACE VPC ENDPOINTS
# ==============================================================================
# Interface endpoints create network interfaces inside the selected subnets.
#
# ECS tasks need HTTPS access to those endpoint network interfaces.
#
# We therefore allow TCP/443 only from the ECS security group.
# ==============================================================================

resource "aws_security_group" "endpoints" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    description = "Allow outbound traffic from VPC endpoints"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpce-sg"
  })
}


# ==============================================================================
# ECR API INTERFACE ENDPOINT
# ==============================================================================
# Provides private connectivity to the Amazon ECR API.
#
# ECS uses this endpoint for ECR API operations such as retrieving image
# metadata and authentication-related information.
# ==============================================================================

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id = var.vpc_id

  service_name = "com.amazonaws.${var.aws_region}.ecr.api"

  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_app_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecr-api-endpoint"
  })
}


# ==============================================================================
# ECR DOCKER REGISTRY INTERFACE ENDPOINT
# ==============================================================================
# Provides private connectivity to the ECR Docker Registry endpoint.
#
# ECS uses this endpoint while pulling Docker image manifests and layers from
# the ECR repository.
# ==============================================================================

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id = var.vpc_id

  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"

  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_app_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecr-dkr-endpoint"
  })
}


# ==============================================================================
# S3 GATEWAY ENDPOINT
# ==============================================================================
# Amazon ECR stores Docker image layers in Amazon S3.
#
# The S3 gateway endpoint allows private subnet resources to communicate with
# S3 through the VPC without using the NAT Gateway.
#
# Unlike interface endpoints, gateway endpoints are associated with route
# tables rather than subnet network interfaces.
# ==============================================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id = var.vpc_id

  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_app_route_table_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  })
}


# ==============================================================================
# CLOUDWATCH LOGS INTERFACE ENDPOINT
# ==============================================================================
# Allows ECS tasks to send container logs to CloudWatch Logs privately.
#
# Traffic uses HTTPS/TCP 443 and is permitted by the endpoint security group
# only from ECS tasks.
# ==============================================================================

resource "aws_vpc_endpoint" "logs" {
  vpc_id = var.vpc_id

  service_name = "com.amazonaws.${var.aws_region}.logs"

  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_app_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-logs-endpoint"
  })
}


# ==============================================================================
# SECRETS MANAGER INTERFACE ENDPOINT
# ==============================================================================
# Allows ECS tasks to retrieve application secrets from AWS Secrets Manager
# without routing that traffic through the NAT Gateway.
# ==============================================================================

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id = var.vpc_id

  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"

  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_app_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints.id
  ]

  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-secrets-manager-endpoint"
  })
}
