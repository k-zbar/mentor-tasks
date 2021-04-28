# Mention availability zones for infrastructure
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "MY-VPC"
  }
}

# Create IGW
resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "1-IGW"
  }
}

# Create NAT gateway for private subnets
resource "aws_nat_gateway" "gw-1" {
  allocation_id = aws_eip.eip-nat-gateway.id
  subnet_id     = aws_subnet.private-subnets[0].id

  tags = {
    Name = "1-GW-NAT"
  }
}

# Create private subnets
resource "aws_subnet" "private-subnets" {
  count             = length(var.pr-subnets)
  cidr_block        = var.pr-subnets[count.index]
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Private_subnet"
  }
}

# Create public subnets
resource "aws_subnet" "public-subnets" {
  count                   = length(var.pub-subnets)
  cidr_block              = var.pub-subnets[count.index]
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_subnet"
  }
}

# Create route for public subnet in default route table
resource "aws_route" "public-route-1" {
  route_table_id         = aws_vpc.my_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-1.id
}

# Create table for private subnets
resource "aws_route_table" "private-route-1" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw-1.id
  }

  tags = {
    Name = "1_Private_route"
  }
}

# Create association private route table with 1 private subnet
resource "aws_route_table_association" "to_private-1" {
  subnet_id      = aws_subnet.private-subnets[0].id
  route_table_id = aws_route_table.private-route-1.id
}

# Create association private route table with 2 private subnet
resource "aws_route_table_association" "to_private-2" {
  subnet_id      = aws_subnet.private-subnets[1].id
  route_table_id = aws_route_table.private-route-1.id
}

# Create elastic IP for NAT Gateway
resource "aws_eip" "eip-nat-gateway" {}