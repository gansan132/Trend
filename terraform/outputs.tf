output "vpc_id" {
  description = "Created VPC ID"
  value       = aws_vpc.trend_vpc.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.trend_vpc.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "availability_zones" {
  description = "Selected Availability Zones"
  value       = local.availability_zones
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.trend_igw.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.trend_nat.id
}
