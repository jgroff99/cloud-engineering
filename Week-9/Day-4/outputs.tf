output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs keyed by name"
  value       = { for k, v in aws_subnet.this : k => v.id if v.map_public_ip_on_launch }
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs keyed by name"
  value       = { for k, v in aws_subnet.this : k => v.id if !v.map_public_ip_on_launch }
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "instance_private_ips" {
  description = "Private IPs of app instances keyed by subnet name"
  value       = { for k, v in aws_instance.app : k => v.private_ip }
}

output "instance_ids" {
  description = "Instance IDs keyed by subnet name"
  value       = { for k, v in aws_instance.app : k => v.id }
}
