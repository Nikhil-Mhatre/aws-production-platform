# ==============================================================================
# GENERAL CONFIGURATION
# These variables define the basic identity and scope of the VPC module.
# ==============================================================================

variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
  # Note for juniors: This prefix helps keep your AWS account organized.
  # If you pass "prod-backend" here, resources will be named "prod-backend-vpc",
  # "prod-backend-igw", etc.[cite: 3]
}

variable "tags" {
  description = "Additional tags applied to VPC resources."
  type        = map(string)
  default     = {}
  # Tags are key-value pairs used for billing and resource tracking.
  # Setting a default = {} means this variable is optional[cite: 3].
}

# ==============================================================================
# NETWORK ADDRESSING (CIDRs) & AVAILABILITY ZONES
# These variables dictate the size and physical location of your network.
# ==============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  # The CIDR block defines the total pool of IP addresses available in this VPC.
  # Example: "10.0.0.0/16" provides 65,536 IP addresses[cite: 3].
}

variable "availability_zones" {
  description = "Availability Zones to use."
  type        = list(string)

  # The validation block is a great safety feature! It prevents Terraform
  # from running if the user tries to create a VPC in only one Availability Zone,
  # ensuring our architecture is highly available (fault-tolerant)[cite: 3].
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per Availability Zone."
  type        = list(string)
  # You must provide a list of CIDRs here.
  # Example: ["10.0.1.0/24", "10.0.2.0/24"][cite: 3].
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets, one per Availability Zone."
  type        = list(string)
  # These map to the mid-tier subnets where your application servers live[cite: 3].
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets, one per Availability Zone."
  type        = list(string)
  # These map to the most secure subnets where databases reside (no internet access)[cite: 3].
}

# ==============================================================================
# NAT GATEWAY CONFIGURATION
# These flags control how outbound internet traffic is handled for private subnets.
# ==============================================================================

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway resources for private application subnet egress."
  type        = bool
  default     = false
  # Since NAT Gateways cost money just for existing, they are turned off by default.
  # Set this to 'true' if your private apps need to download updates or reach external APIs[cite: 3].
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for all private application subnets. Recommended for lower-cost dev environments."
  type        = bool
  default     = true
  # If true, all private subnets share ONE NAT Gateway (cheaper, but less fault-tolerant).
  # If false, Terraform creates one NAT Gateway PER Availability Zone (more expensive,
  # but recommended for production so an AZ outage doesn't break outbound internet)[cite: 3].
}
