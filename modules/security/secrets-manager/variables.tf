variable "secret_name" {
  type        = string
  description = "Name or relative sub-path of the secret (e.g., 'tools/github-token')"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS Customer Managed Key used to encrypt this secret"
}

variable "tenant_id" {
  type        = string
  description = "Optional tenant identifier for tenant-scoped secrets. If null, treated as a platform secret"
  default     = null
}

variable "environment" {
  type        = string
  description = "Deployment environment (local, dev, prod)"
  default     = "local"
}

variable "project_name" {
  type        = string
  description = "Base platform name for resource naming"
  default     = "ai-agent-platform"
}

variable "description" {
  type        = string
  description = "Description of the secret purpose"
  default     = null
}

variable "secret_string" {
  type        = string
  description = "Initial secret value (plaintext or JSON). If null, only the secret container is created"
  default     = null
  sensitive   = true
}

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days before permanent deletion (0 allows immediate deletion, ideal for local/dev)"
  default     = 0
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to attach to the secret"
  default     = {}
}
