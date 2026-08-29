# ==============================================================================
# ECR REPOSITORY (Elastic Container Registry)
# ECR is AWS's managed Docker container registry. Think of it like a private
# Docker Hub hosted inside your AWS account to store your container images.
# ==============================================================================
resource "aws_ecr_repository" "this" {
  # Names the repository using the project name and environment (e.g., "myapp-dev").
  name = "${var.project_name}-${var.environment}"

  # IMMUTABILITY BEST PRACTICE:
  # Setting this to "IMMUTABLE" prevents anyone or any CI/CD pipeline from overwriting
  # an existing image tag (e.g., pushing a new build to "v1.0.0").
  # This guarantees reproducible deployments and prevents accidental or malicious tampering.
  image_tag_mutability = "IMMUTABLE"

  # SECURITY BEST PRACTICE:
  # Automatically scans every container image for known software vulnerabilities (CVEs)
  # as soon as it is pushed to the repository.
  image_scanning_configuration {
    scan_on_push = true
  }

  # ENCRYPTION:
  # Uses AWS-managed server-side encryption (AES256) to ensure container images
  # are encrypted at rest without any extra KMS key management costs.
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================================
# ECR LIFECYCLE POLICY
# Docker images can be several gigabytes in size. Storing hundreds of old, unused
# build images can silently drive up AWS storage costs. A lifecycle policy
# automatically cleans up old images to keep costs under control.
# ==============================================================================
resource "aws_ecr_lifecycle_policy" "this" {
  # Associates this cleanup policy directly with the repository created above.
  repository = aws_ecr_repository.this.name

  # 'jsonencode' converts native Terraform (HCL) maps into the JSON format AWS expects.
  policy = jsonencode({
    rules = [
      {
        # Rule execution order (lower numbers execute first).
        rulePriority = 1
        description  = "Retain the most recent 5 images"

        selection = {
          tagStatus   = "any"                # Applies to both tagged and untagged images
          countType   = "imageCountMoreThan" # Triggers when image count exceeds the threshold
          countNumber = 5                    # Retains the 5 newest images
        }

        # Automatically deletes (expires) any image beyond the 5 most recent.
        action = {
          type = "expire"
        }
      }
    ]
  })
}
