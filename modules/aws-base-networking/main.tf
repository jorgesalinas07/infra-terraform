/**
 * # ioet/infra-terraform-modules/aws-base-networking
 *
 * This module will create a VPC, and it's associated resources. Resources are:
 *
 * - VPC itself
 * - N private subnet for each AZ provided 
 * - N public subnet for each AZ provided
 * - One internet gateway, associated with the public subnets
 * - One NAT gateway for each private subnet, each associated to one private subnet
 * - One Elastic IP for each NAT gateway
 * - One route table for each subnet
 * - One fully permissive NACL for each subnet
 *
 */

data "aws_region" "current" {}

######################################################################
# VPC
######################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support
  tags                 = merge({ Name = var.vpc_name }, var.vpc_tags)
}

######################################################################
# Subnets
######################################################################

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr_blocks)
  cidr_block              = element(var.public_subnets_cidr_blocks, count.index)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  tags                    = merge({ Name = "${var.vpc_name}-public-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}" }, var.public_subnets_tags)
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets_cidr_blocks)
  cidr_block              = element(var.private_subnets_cidr_blocks, count.index)
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = false
  tags                    = merge({ Name = "${var.vpc_name}-private-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}" }, var.private_subnets_tags)
}

######################################################################
# Internet / NAT Gateways
######################################################################

resource "aws_internet_gateway" "this" {
  count  = length(var.public_subnets_cidr_blocks) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-gw"
  }
}

resource "aws_eip" "nat_gateway" {
  count = length(var.public_subnets_cidr_blocks) > 0 ? length(var.public_subnets_cidr_blocks) : 0
  vpc   = true
  tags = {
    Name = "${var.vpc_name}-ngw-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnets_cidr_blocks) > 0 ? length(var.public_subnets_cidr_blocks) : 0
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.nat_gateway.*.id, count.index)
  tags = {
    Name = "${var.vpc_name}-ngw-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}"
  }
}

######################################################################
# Routes and Route Tables
######################################################################

resource "aws_route_table" "public" {
  count  = length(var.public_subnets_cidr_blocks) > 0 ? length(var.public_subnets_cidr_blocks) : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-public-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}"
  }
}

resource "aws_route" "public" {
  count                  = length(var.public_subnets_cidr_blocks) > 0 ? length(var.public_subnets_cidr_blocks) : 0
  route_table_id         = element(aws_route_table.public.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr_blocks) > 0 ? length(var.public_subnets_cidr_blocks) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = length(var.public_subnets_cidr_blocks) > 0 ? length(var.private_subnets_cidr_blocks) : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-private-${var.availability_zones[count.index % length(var.availability_zones)]}-${count.index}"
  }
}

resource "aws_route" "private" {
  count                  = length(var.public_subnets_cidr_blocks) > 0 ? length(var.private_subnets_cidr_blocks) : 0
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.public_subnets_cidr_blocks) > 0 ? length(var.private_subnets_cidr_blocks) : 0
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

######################################################################
# NACLs
######################################################################

resource "aws_network_acl" "public" {
  count      = length(var.public_subnets_cidr_blocks) > 0 ? 1 : 0
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public.*.id
  tags = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_network_acl_rule" "ingress_public" {
  count          = length(var.public_subnets_cidr_blocks) > 0 ? 1 : 0
  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "egress_public" {
  count          = length(var.public_subnets_cidr_blocks) > 0 ? 1 : 0
  network_acl_id = aws_network_acl.public[0].id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "private" {
  count      = length(var.private_subnets_cidr_blocks) > 0 ? 1 : 0
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private.*.id
  tags = {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_network_acl_rule" "ingress_private" {
  count          = length(var.private_subnets_cidr_blocks) > 0 ? 1 : 0
  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "egress_private" {
  count          = length(var.private_subnets_cidr_blocks) > 0 ? 1 : 0
  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

######################################################################
# Default security group
######################################################################

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.vpc_name}-default"
  }
}
