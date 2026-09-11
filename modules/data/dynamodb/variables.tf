variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

variable "environment" {
  type        = string
  description = "Deployment environment (local, dev, prod)"
  default     = "local"
}

variable "project_name" {
  type        = string
  description = "Base platform name for tagging"
  default     = "ai-agent-platform"
}

variable "hash_key" {
  type        = string
  description = "Partition key attribute name (e.g. 'tenant_id')"
}

variable "range_key" {
  type        = string
  description = "Sort key attribute name (e.g. 'session_id'). Makes the primary key composite."
  default     = null
}

variable "attributes" {
  type = list(object({
    name = string
    type = string # "S" = String, "N" = Number, "B" = Binary
  }))
  description = "List of attributes to declare. Only declare attributes used in keys or GSI/LSI indexes."
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string # "ALL", "KEYS_ONLY", or "INCLUDE"
    non_key_attributes = list(string)
  }))
  description = "Optional Global Secondary Indexes for alternate query patterns"
  default     = []
}

variable "billing_mode" {
  type        = string
  description = "DynamoDB billing mode: PAY_PER_REQUEST (serverless, ideal for SaaS) or PROVISIONED"
  default     = "PAY_PER_REQUEST"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for server-side encryption. Should be the tenant CMK for tenant tables."
  default     = null
}

variable "ttl_attribute" {
  type        = string
  description = "Name of the TTL attribute. Items with this attribute set will auto-expire (useful for session state)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the table"
  default     = {}
}
