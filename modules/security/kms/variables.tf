variable "key_scope" {
  type        = string
  description = "Scope or identifier of the key (e.g., 'platform', 'tenant-ref', or specific service)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. local, dev, prod)"
  default     = "local"
}

variable "project_name" {
  type        = string
  description = "Platform name for naming convention"
  default     = "ai-agent-platform"
}

variable "description" {
  type        = string
  description = "Purpose of the KMS key"
  default     = null
}

variable "deletion_window_in_days" {
  type        = number
  description = "Waiting period before key destruction (7-30 days)"
  default     = 7
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable automatic yearly key rotation"
  default     = true
}

variable "custom_key_policy" {
  type        = string
  description = "Optional custom IAM JSON policy. If null, a secure default account policy is applied"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the key"
  default     = {}
}
