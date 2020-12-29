# we have to say terraform which cloud we are using

provider "aws" {
  region = var.region
}


# Create VPC

resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "myapp-vpc-${local.ws}"
    Department="Finance"
  }
}

# data source for availaiblity zones

data "aws_availability_zones" "available" {
  state = "available"
}

# Create multiple subnets

resource "aws_subnet" "subnet" {
  count = 4
  vpc_id     = aws_vpc.example.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "subnet1-${local.ws}"
    Department = "Finance"
  }
}

# get list of azs for current region and from the list get elements one by one by passing index value