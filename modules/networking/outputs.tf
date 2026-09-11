output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "agent_compute_security_group_id" {
  description = "ID of the security group for agent compute workers (ECS / Lambda)"
  value       = aws_security_group.agent_compute.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC interface endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
