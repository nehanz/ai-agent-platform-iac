variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name identifier for the Redis cache cluster"
  type        = string
  default     = "agent-cache"
}

variable "vpc_id" {
  description = "VPC ID where the Redis security group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for the Redis subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs permitted to access Redis on port 6379"
  type        = list(string)
  default     = []
}

variable "node_type" {
  description = "Compute and memory capacity node type for the Redis cache"
  type        = string
  default     = "cache.t4g.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (primary + replicas) in the replication group"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encryption at rest"
  type        = string
  default     = null
}

variable "transit_encryption_enabled" {
  description = "Whether to enable in-transit TLS encryption"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all ElastiCache resources"
  type        = map(string)
  default     = {}
}
