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
# LOG RETENTION
# ==============================================================================

variable "log_retention_days" {
  description = "Number of days CloudWatch Logs should be retained"
  type        = number

  validation {
    condition = contains(
      [
        1,
        3,
        5,
        7,
        14,
        30,
        60,
        90,
        120,
        150,
        180,
        365,
        400,
        545,
        731,
        1096,
        1827,
        2192,
        2557,
        2922,
        3288,
        3653,
        0
      ],
      var.log_retention_days
    )

    error_message = "log_retention_days must be a valid CloudWatch Logs retention value."
  }
}


# ==============================================================================
# COMMON TAGS
# ==============================================================================

variable "tags" {
  description = "Common tags applied to CloudWatch resources"
  type        = map(string)
  default     = {}
}
