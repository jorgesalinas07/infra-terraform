output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_subnet_arns" {
  value = aws_subnet.private.*.arn
}

output "private_subnet_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_subnet_arns" {
  value = aws_subnet.public.*.arn
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.public.*.cidr_block
}

output "internet_gateway_id" {
  value = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].id : null
}

output "internet_gateway_arn" {
  value = length(aws_internet_gateway.this) > 0 ? aws_internet_gateway.this[0].arn : null
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this.*.id
}

output "nat_gateway_allocation_ids" {
  value = aws_nat_gateway.this.*.allocation_id
}

output "nat_gateway_private_ips" {
  value = aws_nat_gateway.this.*.private_ip
}

output "nat_gateway_public_ips" {
  value = aws_nat_gateway.this.*.public_ip
}

output "nat_gateway_public_network_interface_ids" {
  value = aws_nat_gateway.this.*.network_interface_id
}

output "public_route_table_ids" {
  value = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.private.*.id
}

output "public_network_acl_ids" {
  value = aws_network_acl.public.*.id
}

output "public_network_acl_arns" {
  value = aws_network_acl.public.*.arn
}

output "private_network_acl_ids" {
  value = aws_network_acl.private.*.id
}

output "private_network_acl_arns" {
  value = aws_network_acl.private.*.arn
}
