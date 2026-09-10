variable "bucket_prefix" {
  type        = string
  description = "Prefix for the S3 bucket name (e.g., 'ai-agent-platform-local'). A random suffix is appended for global uniqueness."
  default     = "ai-agent-platform"
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

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS CMK used for server-side encryption of all audit objects"
}

variable "object_lock_retention_days" {
  type        = number
  description = "Number of days audit objects are locked in COMPLIANCE mode (cannot be deleted by anyone)"
  default     = 1
}

variable "glacier_transition_days" {
  type        = number
  description = "Number of days before objects transition to Glacier Flexible Retrieval storage tier (cost optimization)"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the bucket"
  default     = {}
}
