# ==============================================================================
# LOAD BALANCER
# ==============================================================================

output "load_balancer_id" {
  description = "Application Load Balancer ID"
  value       = aws_lb.this.id
}

output "load_balancer_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}


# ==============================================================================
# TARGET GROUP
# ==============================================================================

output "target_group_id" {
  description = "Target group ID"
  value       = aws_lb_target_group.this.id
}

output "target_group_arn" {
  description = "Target group ARN used by ECS"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Target group name"
  value       = aws_lb_target_group.this.name
}


# ==============================================================================
# LISTENER
# ==============================================================================

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}
