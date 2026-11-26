terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get available AWS Availability Zones

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  common_tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Create VPC

resource "aws_vpc" "trend_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# Internet Gateway

resource "aws_internet_gateway" "trend_igw" {
  vpc_id = aws_vpc.trend_vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# Public Subnets

resource "aws_subnet" "public_subnets" {
  count = 2

  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                     = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  })
}

# Private Subnets

resource "aws_subnet" "private_subnets" {
  count = 2

  vpc_id            = aws_vpc.trend_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name                              = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# Public Route Table

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.trend_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

# Associate Public Subnets

resource "aws_route_table_association" "public_association" {
  count = 2

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip"
  })

  depends_on = [
    aws_internet_gateway.trend_igw
  ]
}

# NAT Gateway

resource "aws_nat_gateway" "trend_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat"
  })

  depends_on = [
    aws_internet_gateway.trend_igw
  ]
}

# Private Route Table

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.trend_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.trend_nat.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt"
  })
}

# Associate Private Subnets

resource "aws_route_table_association" "private_association" {
  count = 2

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
