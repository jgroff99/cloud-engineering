# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# Subnets (all four from one block)
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, each.value.newbits, each.value.netnum)
  availability_zone = data.aws_availability_zones.available.names[
    each.value.public ? index(keys(local.public_subnets), each.key) : index(keys(local.private_subnets), each.key)
  ]
  map_public_ip_on_launch = each.value.public

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Tier = each.value.public ? "public" : "private"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

# Public route table associations
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

# Security group
resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-sg-"
  description = "App server security group"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group ingress rules via for_each
resource "aws_vpc_security_group_ingress_rule" "app" {
  for_each = var.security_group_rules

  security_group_id = aws_security_group.app.id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr_blocks[0]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ingress-${each.key}"
  })
}

# Security group egress rule (allow all outbound)
resource "aws_vpc_security_group_egress_rule" "app" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-egress-all"
  })
}
