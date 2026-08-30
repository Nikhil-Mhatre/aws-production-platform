# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as dev or prod"
  type        = string
}


# ==============================================================================
# DATABASE ENGINE
# ==============================================================================

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16"
}


# ==============================================================================
# DATABASE INSTANCE
# ==============================================================================

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial database storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage RDS can automatically scale to in GiB"
  type        = number
  default     = 100
}


# ==============================================================================
# DATABASE CONFIGURATION
# ==============================================================================

variable "database_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "launchpad"
}

variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "launchpad_admin"
}


# ==============================================================================
# NETWORKING
# ==============================================================================

variable "private_db_subnet_ids" {
  description = "Private database subnet IDs used by the RDS subnet group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID assigned to the RDS instance"
  type        = string
}


# ==============================================================================
# BACKUPS
# ==============================================================================

variable "backup_retention_period" {
  description = "Number of days automated RDS backups are retained"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred daily backup window"
  type        = string
  default     = "03:00-04:00"
}


# ==============================================================================
# MAINTENANCE
# ==============================================================================

variable "maintenance_window" {
  description = "Preferred weekly maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}


# ==============================================================================
# LIFECYCLE
# ==============================================================================

variable "deletion_protection" {
  description = "Prevent accidental deletion of the RDS instance"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the RDS instance"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of during maintenance"
  type        = bool
  default     = false
}


# ==============================================================================
# COMMON TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags applied to RDS resources"
  type        = map(string)
  default     = {}
}
