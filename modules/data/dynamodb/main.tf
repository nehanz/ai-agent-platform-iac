locals {
  full_table_name = "${var.project_name}-${var.environment}-${var.table_name}"
}

resource "aws_dynamodb_table" "this" {
  name         = local.full_table_name
  billing_mode = var.billing_mode

  # Partition key — every item in DynamoDB MUST have this attribute.
  # Using tenant_id as the partition key enforces data-model-level tenant isolation:
  # a query can only retrieve items for a single partition key value at a time.
  hash_key = var.hash_key

  # Sort key is optional. When present, the primary key becomes composite:
  # (hash_key, range_key) together must be unique per item.
  range_key = var.range_key

  # DynamoDB requires you to pre-declare ONLY the attributes used in keys and indexes.
  # Regular item attributes (e.g. "status", "created_at") are schema-free — declare nothing.
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type # "S"=String, "N"=Number, "B"=Binary
    }
  }

  # Global Secondary Index — enables alternate query patterns.
  # For example: query sessions by agent_id instead of tenant_id.
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
    }
  }

  # Server-Side Encryption with KMS.
  # If kms_key_arn is provided → use tenant Customer Managed Key (per-tenant isolation).
  # If kms_key_arn is null → use AWS-managed key (aws/dynamodb).
  dynamic "server_side_encryption" {
    for_each = var.kms_key_arn != null ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }

  # TTL (Time To Live): DynamoDB will automatically delete items whose TTL
  # attribute value (a Unix timestamp) is in the past.
  # Useful for: agent sessions (expire after 24h), rate-limit windows, temp tokens.
  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute
    }
  }

  # Continuous backup — allows table restoration to any second within the last 35 days.
  # Critical for production multi-tenant SaaS data protection.
  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name        = local.full_table_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
