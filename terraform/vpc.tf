resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "terraform-aws-vpc"
  }

}

resource "aws_eip" "nat" {
  count = length(split(",", var.private_subnets_cidr))
  vpc   = true
  tags = {
    Name = "EIP-${count.index}"
  }
}

resource "aws_nat_gateway" "ng-main" {
  count         = length(split(",", var.private_subnets_cidr))
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = {
    Name = "Nat-GW-${count.index}"
  }
}

resource "aws_route_table" "private" {
  count  = length(split(",", var.private_subnets_cidr))
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng-main[count.index].id
  }
  tags = {
    Name = "Private-RT-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(split(",", var.private_subnets_cidr))
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_internet_gateway" "ig-main" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Internet-GW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-main.id
  }
  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(split(",", var.public_subnets_cidr))
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


//create the public subnets
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(split(",", var.public_subnets_cidr))
  cidr_block        = element(split(",", var.public_subnets_cidr), count.index)
  availability_zone = element(split(",", var.azs), count.index)

  tags = {
    Name = "${var.name}-public-${element(split(",", var.azs), count.index)}"
  }
}

// Create the Private Subnets
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main_vpc.id
  count      = length(split(",", var.private_subnets_cidr))
  cidr_block = element(split(",", var.private_subnets_cidr), count.index)

  availability_zone       = element(split(",", var.azs), count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private-${element(split(",", var.azs), count.index)}"
  }
}
