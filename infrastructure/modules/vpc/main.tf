# ==============================================================================
# LOCALS
# Local values act like temporary variables inside this specific file.
# ==============================================================================

# Defines a block for local variables. Example: locals { environment = "dev" }
locals {
  # The 'merge' function combines multiple maps into one. Example: merge({a=1}, {b=2}) becomes {a=1, b=2}
  common_tags = merge(
    # Starts the first map containing default key-value pairs. Example: { my_key = "my_value" }
    {
      # Sets a tag key 'ManagedBy' to 'Terraform'. Example: Owner = "DevOpsTeam"
      ManagedBy = "Terraform"
      # Sets a tag key 'Module' to 'vpc'. Example: Component = "Networking"
      Module = "vpc"
      # Ends the first map. Example: }
    },
    # Injects the second map from a user-defined variable. Example: var.tags = { Env = "Prod" }
    var.tags
    # Ends the merge function. Example: )
  )

  # Calculates the number of NAT gateways using conditional logic (condition ? true_val : false_val).
  # Example: nat_gateway_count = true ? true ? 1 : 3 : 0
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  # Ends the locals block. Example: }
}

# ==============================================================================
# VPC (Virtual Private Cloud)
# ==============================================================================

# Declares a resource of type "aws_vpc" with the local Terraform name "this". Example: resource "aws_instance" "web" {
resource "aws_vpc" "this" {
  # Sets the IPv4 address range for the VPC. Example: cidr_block = "10.0.0.0/16"
  cidr_block = var.vpc_cidr

  # Enables DNS resolution within the VPC.
  enable_dns_support = true
  # Allows AWS to assign public DNS hostnames to instances.
  enable_dns_hostnames = true
  # When both of these are true,
  # AWS automatically gives your instance a recognizable name, such as ec2-203-0-113-50.compute-1.amazonaws.com

  # Applies tags to the VPC by merging common tags with a specific Name tag. Example: tags = { Name = "my-vpc" }
  tags = merge(local.common_tags, {
    # Dynamically generates the VPC name using string interpolation. Example: Name = "prod-vpc"
    Name = "${var.name}-vpc"
    # Ends the map and merge function for tags.
  })
  # Ends the aws_vpc resource block.
}

# ==============================================================================
# INTERNET GATEWAY (IGW)
# ==============================================================================

# Declares an "aws_internet_gateway" resource named "this".
resource "aws_internet_gateway" "this" {
  # Attaches the gateway to the VPC created above using its ID. Example: vpc_id = "vpc-0abcd1234"
  vpc_id = aws_vpc.this.id

  # Merges common tags with a specific Name tag for the Internet Gateway. Example: tags = { Name = "my-igw" }
  tags = merge(local.common_tags, {
    # Dynamically sets the IGW name. Example: Name = "prod-igw"
    Name = "${var.name}-igw"
    # Ends the map and merge function.
  })
  # Ends the aws_internet_gateway resource block.
}

# ==============================================================================
# SUBNETS
# ==============================================================================

# Declares a public subnet resource.
resource "aws_subnet" "public" {
  # Creates multiple subnets based on the number of provided Availability Zones. Example: count = 3
  count = length(var.availability_zones)

  # Links the subnet to the VPC using the VPC's ID. Example: vpc_id = "vpc-0abcd1234"
  vpc_id = aws_vpc.this.id

  # Assigns a specific CIDR block from the list variable based on the current loop index. Example: cidr_block = "10.0.1.0/24"
  cidr_block = var.public_subnet_cidrs[count.index]

  # Assigns the subnet to a specific Availability Zone based on the loop index. Example: availability_zone = "us-east-1a"
  availability_zone = var.availability_zones[count.index]

  # Prevents instances launched here from getting a public IP automatically.
  map_public_ip_on_launch = false

  # Assigns tags, including a dynamically numbered Name tag. Example: tags = { Tier = "public" }
  tags = merge(local.common_tags, {
    # Names the subnet appending the loop index + 1 (so it starts at 1, not 0). Example: Name = "prod-public-1"
    Name = "${var.name}-public-${count.index + 1}"
    # Adds a custom tag identifying the network tier. Example: Tier = "frontend"
    Tier = "public"
    # Ends the map and merge function.
  })
  # Ends the public aws_subnet block.
}

# Declares a private subnet resource for applications. Example: resource "aws_subnet" "backend" {
resource "aws_subnet" "private_app" {
  # Loops to create a private app subnet for each Availability Zone. Example: count = 2
  count = length(var.availability_zones)

  # Links the subnet to the VPC. Example: vpc_id = aws_vpc.this.id
  vpc_id = aws_vpc.this.id
  # Selects the CIDR block from the private_app list using the loop index. Example: cidr_block = "10.0.10.0/24"
  cidr_block = var.private_app_subnet_cidrs[count.index]
  # Places the subnet in the corresponding AZ. Example: availability_zone = "us-west-2b"
  availability_zone = var.availability_zones[count.index]

  # Assigns tags to easily identify the private app subnets. Example: tags = { Env = "dev" }
  tags = merge(local.common_tags, {
    # Generates a numbered name. Example: Name = "prod-private-app-1"
    Name = "${var.name}-private-app-${count.index + 1}"
    # Tags the tier for potential use in data lookups later. Example: Tier = "application"
    Tier = "private-app"
    # Ends the map and merge function.
  })
  # Ends the private_app aws_subnet block.
}

# Declares a private subnet resource specifically for databases. Example: resource "aws_subnet" "database" {
resource "aws_subnet" "private_db" {
  # Loops to create a private DB subnet for each AZ. Example: count = 3
  count = length(var.availability_zones)

  # Links the subnet to the VPC. Example: vpc_id = "vpc-0abcd1234"
  vpc_id = aws_vpc.this.id
  # Fetches the corresponding DB CIDR block. Example: cidr_block = "10.0.20.0/24"
  cidr_block = var.private_db_subnet_cidrs[count.index]
  # Sets the AZ using the current loop index. Example: availability_zone = "eu-central-1a"
  availability_zone = var.availability_zones[count.index]

  # Applies identifying tags. Example: tags = { DB = "postgres" }
  tags = merge(local.common_tags, {
    # Dynamically names the DB subnet. Example: Name = "prod-private-db-2"
    Name = "${var.name}-private-db-${count.index + 1}"
    # Sets the tier tag. Example: Tier = "data"
    Tier = "private-db"
    # Ends the map and merge function.
  })
  # Ends the private_db aws_subnet block.
}

# ==============================================================================
# PUBLIC ROUTING
# ==============================================================================

# Declares a route table for the public subnets. Example: resource "aws_route_table" "main" {
resource "aws_route_table" "public" {
  # Associates the route table with our VPC. Example: vpc_id = aws_vpc.this.id
  vpc_id = aws_vpc.this.id

  # Defines an inline route inside the route table block. Example: route { cidr_block = "10.1.0.0/16" ... }
  route {
    # Matches all outbound IPv4 internet traffic. Example: cidr_block = "0.0.0.0/0"
    cidr_block = "0.0.0.0/0"
    # Directs that traffic to the Internet Gateway. Example: gateway_id = "igw-012345"
    gateway_id = aws_internet_gateway.this.id
    # Ends the inline route block.
  }

  # Tags the route table. Example: tags = { Name = "public-routes" }
  tags = merge(local.common_tags, {
    # Names the public route table. Example: Name = "prod-public-rt"
    Name = "${var.name}-public-rt"
    # Ends the map and merge function.
  })
  # Ends the public aws_route_table block.
}

# Associates the public subnets with the public route table. Example: resource "aws_route_table_association" "a" {
resource "aws_route_table_association" "public" {
  # Loops over the public subnets created earlier. Example: count = length(aws_subnet.public)
  count = length(aws_subnet.public)

  # Grabs the ID of the specific subnet in the current loop iteration. Example: subnet_id = "subnet-0abc123"
  subnet_id = aws_subnet.public[count.index].id
  # Connects it to the ID of the public route table. Example: route_table_id = "rtb-012345"
  route_table_id = aws_route_table.public.id
  # Ends the public aws_route_table_association block.
}

# ==============================================================================
# NAT GATEWAYS (Network Address Translation)
# ==============================================================================

# Declares Elastic IPs (Static Public IPs) for the NAT Gateways. Example: resource "aws_eip" "main" {
resource "aws_eip" "nat" {
  # Creates IPs based on the locally calculated NAT gateway count. Example: count = 1
  count = local.nat_gateway_count

  # Specifies that this EIP is for use in a VPC. Example: domain = "vpc"
  domain = "vpc"

  # Tags the Elastic IP. Example: tags = { Name = "nat-ip" }
  tags = merge(local.common_tags, {
    # Dynamically names the EIP. Example: Name = "prod-nat-eip-1"
    Name = "${var.name}-nat-eip-${count.index + 1}"
    # Ends the map and merge function.
  })

  # Ensures the IGW exists before creating EIPs, as EIPs need internet access to provision. Example: depends_on = [aws_internet_gateway.this]
  depends_on = [aws_internet_gateway.this]
  # Ends the aws_eip block.
}

# Declares the NAT Gateway resources. Example: resource "aws_nat_gateway" "main" {
resource "aws_nat_gateway" "this" {
  # Creates NAT Gateways based on the calculated count. Example: count = 3
  count = local.nat_gateway_count

  # Attaches the previously created Elastic IP to the NAT Gateway. Example: allocation_id = "eipalloc-0123"
  allocation_id = aws_eip.nat[count.index].id
  # Places the NAT Gateway in a public subnet (index 0 if single, matching index if multiple). Example: subnet_id = "subnet-0abc"
  subnet_id = var.single_nat_gateway ? aws_subnet.public[0].id : aws_subnet.public[count.index].id

  # Tags the NAT Gateway. Example: tags = { Name = "main-nat" }
  tags = merge(local.common_tags, {
    # Dynamically names the NAT gateway. Example: Name = "prod-nat-1"
    Name = "${var.name}-nat-${count.index + 1}"
    # Ends the map and merge function.
  })

  # Ensures the IGW exists before the NAT Gateway is provisioned. Example: depends_on = [aws_internet_gateway.this]
  depends_on = [aws_internet_gateway.this]
  # Ends the aws_nat_gateway block.
}

# ==============================================================================
# PRIVATE ROUTING
# ==============================================================================

# Declares route tables for the private application subnets. Example: resource "aws_route_table" "private" {
resource "aws_route_table" "private_app" {
  # Creates one route table per Availability Zone. Example: count = 2
  count = length(var.availability_zones)

  # Links the route tables to the VPC. Example: vpc_id = aws_vpc.this.id
  vpc_id = aws_vpc.this.id

  # A dynamic block generates the 'route' block conditionally. Example: dynamic "ingress" { ... }
  dynamic "route" {
    # If enable_nat_gateway is true, loops once ([1]); if false, loops zero times ([]), omitting the route. Example: for_each = var.create ? [1] : []
    for_each = var.enable_nat_gateway ? [1] : []

    # Defines the actual content of the generated route block. Example: content { cidr_block = "..." }
    content {
      # Targets all outbound internet traffic. Example: cidr_block = "0.0.0.0/0"
      cidr_block = "0.0.0.0/0"
      # Points the traffic to the correct NAT Gateway (either the single one, or the AZ-matched one). Example: nat_gateway_id = "nat-0123"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
      # Ends the content block.
    }
    # Ends the dynamic route block.
  }

  # Tags the private app route tables. Example: tags = { Name = "private-rt" }
  tags = merge(local.common_tags, {
    # Generates a numbered name. Example: Name = "prod-private-app-rt-1"
    Name = "${var.name}-private-app-rt-${count.index + 1}"
    # Ends the map and merge function.
  })
  # Ends the private_app aws_route_table block.
}

# Associates the private app subnets with their corresponding route tables. Example: resource "aws_route_table_association" "b" {
resource "aws_route_table_association" "private_app" {
  # Loops over the private app subnets. Example: count = 3
  count = length(aws_subnet.private_app)

  # Gets the subnet ID for the current loop iteration. Example: subnet_id = "subnet-0xyz"
  subnet_id = aws_subnet.private_app[count.index].id
  # Maps it to the matching route table ID. Example: route_table_id = "rtb-0xyz"
  route_table_id = aws_route_table.private_app[count.index].id
  # Ends the private_app aws_route_table_association block.
}

# Declares route tables for the private DB subnets (no outbound internet routes here). Example: resource "aws_route_table" "db" {
resource "aws_route_table" "private_db" {
  # Creates one route table per Availability Zone. Example: count = 3
  count = length(var.availability_zones)

  # Links the DB route tables to the VPC. Example: vpc_id = aws_vpc.this.id
  vpc_id = aws_vpc.this.id

  # Tags the DB route tables. Example: tags = { Name = "db-rt" }
  tags = merge(local.common_tags, {
    # Generates a numbered name. Example: Name = "prod-private-db-rt-1"
    Name = "${var.name}-private-db-rt-${count.index + 1}"
    # Ends the map and merge function.
  })
  # Ends the private_db aws_route_table block.
}

# Associates the private DB subnets with the DB route tables. Example: resource "aws_route_table_association" "c" {
resource "aws_route_table_association" "private_db" {
  # Loops over the DB subnets. Example: count = 3
  count = length(aws_subnet.private_db)

  # Gets the DB subnet ID for the current loop iteration. Example: subnet_id = "subnet-0db1"
  subnet_id = aws_subnet.private_db[count.index].id
  # Maps it to the corresponding DB route table ID. Example: route_table_id = "rtb-0db1"
  route_table_id = aws_route_table.private_db[count.index].id
  # Ends the private_db aws_route_table_association block.
}
