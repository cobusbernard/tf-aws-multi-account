# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name        = "${var.vpc_name}-vpc"
    Environment = "${var.environment}"
    Role        = "${var.vpc_name}"
    System      = "${var.vpc_name}"
  }
}

## Route tables
resource "aws_route_table" "nat_az_1" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "${var.system}-${var.role}-route-${var.aws_region}a"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.system}"
  }
}

resource "aws_route_table" "nat_az_2" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "${var.system}-${var.role}-route-${var.aws_region}b"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.system}"
  }
}

resource "aws_route_table" "nat_az_3" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "${var.system}-${var.role}-route-${var.aws_region}c"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.system}"
  }
}

## Subnets
resource "aws_subnet" "nat_az_1" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.nat_subnets_az_1}"
  availability_zone = "${var.aws_region}a"

  tags {
    Name        = "${var.vpc_name}-public-nat-subnet-${var.aws_region}a"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.vpc_name}"
  }
}

resource "aws_subnet" "nat_az_2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.nat_subnets_az_2}"
  availability_zone = "${var.aws_region}b"

  tags {
    Name        = "${var.vpc_name}-public-nat-subnet-${var.aws_region}b"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.vpc_name}"
  }
}

resource "aws_subnet" "nat_az_3" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.nat_subnets_az_3}"
  availability_zone = "${var.aws_region}c"

  tags {
    Name        = "${var.vpc_name}-public-nat-subnet-${var.aws_region}c"
    Environment = "${var.environment}"
    Role        = "nat"
    System      = "${var.vpc_name}"
  }
}

## Routing
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.vpc_name}-gateway"
    Environment = "${var.environment}"
    Role        = "gateway"
    System      = "${var.vpc_name}"
  }
}

## Subnet routing association
resource "aws_route_table_association" "az_1" {
  subnet_id      = "${aws_subnet.nat_az_1.id}"
  route_table_id = "${aws_route_table.nat_az_1.id}"
}

resource "aws_route_table_association" "az_2" {
  subnet_id      = "${aws_subnet.nat_az_2.id}"
  route_table_id = "${aws_route_table.nat_az_2.id}"
}

resource "aws_route_table_association" "az_3" {
  subnet_id      = "${aws_subnet.nat_az_3.id}"
  route_table_id = "${aws_route_table.nat_az_3.id}"
}

resource "aws_eip" "nat_az_1_eip" {
  vpc = true
}

resource "aws_eip" "nat_az_2_eip" {
  vpc = true
}

resource "aws_eip" "nat_az_3_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw_az_1" {
  allocation_id = "${aws_eip.nat_az_1_eip.id}"
  subnet_id     = "${aws_subnet.nat_az_1.id}"
}

resource "aws_nat_gateway" "nat_gw_az_2" {
  allocation_id = "${aws_eip.nat_az_2_eip.id}"
  subnet_id     = "${aws_subnet.nat_az_2.id}"
}

resource "aws_nat_gateway" "nat_gw_az_3" {
  allocation_id = "${aws_eip.nat_az_3_eip.id}"
  subnet_id     = "${aws_subnet.nat_az_3.id}"
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${var.ssh_key_public}"
}
