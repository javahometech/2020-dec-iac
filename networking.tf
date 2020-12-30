
# Create VPC

resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr
  tags = {
    Name       = "myapp-vpc-${local.ws}"
    Department = "Finance"
  }
}

# Create public subnets

resource "aws_subnet" "public" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.example.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = local.azs[count.index]
  tags = {
    Name       = "public-${count.index + 1}-${local.ws}"
    Department = "Finance"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "javahome-igw"
  }
}

# Route table for public subnets

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route"
  }
}

# Public subnet associations with public route table

resource "aws_route_table_association" "a" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


# Create private subnets

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.example.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index+length(local.azs))
  availability_zone = local.azs[count.index]
  tags = {
    Name       = "private-${count.index + 1}-${local.ws}"
    Department = "Finance"
  }
}

# # Elastic IP

# resource "aws_eip" "nat" {
#   vpc      = true
# }

# # Create NAT Gateway

# resource "aws_nat_gateway" "gw" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.*.id[0]
#   tags = {
#     Name = "NAT Gateway"
#   }
# }


# # Create route table for private subnets and configure NAT Gateway to it

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.example.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.gw.id
#   }

#   tags = {
#     Name = "private-route"
#   }
# }

# resource "aws_route_table_association" "private" {
#   count          = length(local.azs)
#   subnet_id      = aws_subnet.private.*.id[count.index]
#   route_table_id = aws_route_table.private.id
# }