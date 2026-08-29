# ==============================================================================
# LOCALS
# Local values act like temporary variables inside this specific file.
# We use them here to combine default tags with user-provided tags[cite: 1].
# We also calculate exactly how many NAT Gateways we need based on the user's variables[cite: 1].
# ==============================================================================
locals {
  common_tags = merge(
    {
      ManagedBy = "Terraform"
      Module    = "vpc"
    },
    var.tags
  )

  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
}

# ==============================================================================
# VPC (Virtual Private Cloud)
# This is the foundational network boundary for your AWS resources.
# ==============================================================================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  # Enabling DNS support and hostnames allows AWS to assign friendly DNS names
  # to resources (like EC2 instances) inside this VPC[cite: 1].
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-vpc"
  })
}

# ==============================================================================
# INTERNET GATEWAY (IGW)
# This acts as the "door" to the outside internet. Without this, nothing in
# the VPC can talk to the internet, and the internet cannot talk to the VPC[cite: 1].
# ==============================================================================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

# ==============================================================================
# SUBNETS
# Subnets are smaller chunks of the VPC network. We divide them into tiers.
# ==============================================================================

# 1. Public Subnets: Resources here (like Load Balancers) can be reached from the internet.
resource "aws_subnet" "public" {
  # The 'count' meta-argument acts as a loop. It creates one subnet for
  # every Availability Zone (AZ) provided in the variables[cite: 1].
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-${count.index + 1}"
    Tier = "public"
  })
}

# 2. Private App Subnets: Resources here (like backend APIs) cannot be reached
# from the internet, but they can reach OUT to the internet via a NAT Gateway[cite: 1].
resource "aws_subnet" "private_app" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-app-${count.index + 1}"
    Tier = "private-app"
  })
}

# 3. Private DB Subnets: Highly secure tier for databases. These have absolutely
# no internet access (inbound or outbound)[cite: 1].
resource "aws_subnet" "private_db" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-db-${count.index + 1}"
    Tier = "private-db"
  })
}

# ==============================================================================
# PUBLIC ROUTING
# Route tables act like a GPS for network traffic.
# ==============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  # This route sends all outbound traffic (0.0.0.0/0) to the Internet Gateway[cite: 1].
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
  })
}

# This association explicitly links our Public Subnets to the Public Route Table[cite: 1].
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# NAT GATEWAYS (Network Address Translation)
# Allows private resources to download updates from the internet without
# exposing them to inbound internet traffic.
# ==============================================================================

# Creates Elastic IPs (static public IP addresses) for the NAT Gateways to use[cite: 1].
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  })

  # We wait for the Internet Gateway to exist before creating this IP[cite: 1].
  depends_on = [aws_internet_gateway.this]
}

# Creates the actual NAT Gateways and places them inside the Public Subnets[cite: 1].
resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = var.single_nat_gateway ? aws_subnet.public[0].id : aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

# ==============================================================================
# PRIVATE ROUTING
# ==============================================================================

# Private App Route Table: Routes internet-bound traffic to the NAT Gateway[cite: 1].
resource "aws_route_table" "private_app" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  # A 'dynamic' block allows us to conditionally generate this route only if
  # the NAT Gateway is enabled[cite: 1].
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-app-rt-${count.index + 1}"
  })
}

# Associates the Private App Subnets with the Private App Route Table[cite: 1].
resource "aws_route_table_association" "private_app" {
  count = length(aws_subnet.private_app)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

# Private DB Route Table: Notice there are no routes to the internet here,
# ensuring maximum database isolation[cite: 1].
resource "aws_route_table" "private_db" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-db-rt-${count.index + 1}"
  })
}

# Associates the Private DB Subnets with the Private DB Route Table[cite: 1].
resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}
