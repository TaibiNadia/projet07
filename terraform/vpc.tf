resource "aws_vpc" "main_vpc" {
  cidr_block             = var.vpc_cidr
  enable_dns_hostnames   = true
  
  tags = {
    Name = "terraform-aws-vpc"
  }

}
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

resource "aws_eip" "nat" {
  vpc    = true
  tags   = {
    Name = "Nat Elastic Ip"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-main.id
  }
  tags = {
    Name = "Public Routetable"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id
  
  tags = {
    Name = "Private Routetable"
  }
}
resource "aws_route_table_association" "private" {
  count          = length(split(",", var.private_subnets_cidr))
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}


resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "eu-west-3a"
  tags = {
    Name = "Public Subnet"
  }
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}

// Create the Private Subnets
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main_vpc.id
  count                   = length(split(",", var.private_subnets_cidr))
  cidr_block              = element(split(",", var.private_subnets_cidr), count.index)
 
 availability_zone       = element(split(",", var.azs), count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-${var.environment}-private-${element(split(",", var.azs), count.index)}"
  }  
}

output "private_subnets" {
   value = join(",", aws_subnet.private.*.id)
}


resource "aws_internet_gateway" "ig-main" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_nat_gateway" "ng-main" {
  allocation_id          = aws_eip.nat.id
  subnet_id              = aws_subnet.public.id
  tags = {
    Name = "Nat Gateway"
  }
}
