locals {
  cluster_full_name = "${var.project_name}-${var.environment}-${var.cluster_name}"
}

# ─── ElastiCache Subnet Group ─────────────────────────────────────────────────
# Directs Redis nodes into private subnets across multiple Availability Zones.
resource "aws_elasticache_subnet_group" "this" {
  name        = "${local.cluster_full_name}-subnet-group"
  description = "Private subnet group for ${local.cluster_full_name}"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${local.cluster_full_name}-subnet-group"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Security Group for Redis ─────────────────────────────────────────────────
# Enforces strict network isolation: only allows inbound TCP traffic on port 6379
# from authorized compute security groups (ECS agent tasks and Lambda workers).
resource "aws_security_group" "this" {
  name        = "${local.cluster_full_name}-sg"
  description = "Security group for Redis session cache cluster"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "Redis port from agent compute workers"
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.cluster_full_name}-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Redis Parameter Group ────────────────────────────────────────────────────
# Configures eviction policies for agent session cache and token rate limits.
resource "aws_elasticache_parameter_group" "this" {
  name        = "${local.cluster_full_name}-params"
  family      = "redis7"
  description = "Custom parameter group for ${local.cluster_full_name}"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.cluster_full_name}-params"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Redis Replication Group ──────────────────────────────────────────────────
# High-performance in-memory cache with at-rest KMS encryption and in-transit TLS.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.cluster_full_name
  description          = "Redis replication group for AI agent session cache and rate limiting"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.this.name
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.this.id]

  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn
  transit_encryption_enabled = var.transit_encryption_enabled
  auto_minor_version_upgrade = true

  tags = merge(
    var.tags,
    {
      Name        = local.cluster_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
