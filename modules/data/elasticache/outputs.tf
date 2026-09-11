output "replication_group_id" {
  description = "ID of the Redis replication group"
  value       = aws_elasticache_replication_group.this.id
}

output "replication_group_arn" {
  description = "ARN of the Redis replication group"
  value       = aws_elasticache_replication_group.this.arn
}

output "primary_endpoint_address" {
  description = "Endpoint address of the primary Redis node for read/write access"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Endpoint address of the Redis reader endpoint for read replicas"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port number on which the Redis cluster accepts connections"
  value       = aws_elasticache_replication_group.this.port
}

output "security_group_id" {
  description = "ID of the security group protecting the Redis cluster"
  value       = aws_security_group.this.id
}
