variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "description" {
  description = "Description for the Verified Permissions policy store"
  type        = string
  default     = "Fine-grained Cedar policy authorization store for AI Agent Platform"
}

variable "validation_mode" {
  description = "Validation mode for the policy store (STRICT enforces schema validation on all policies)"
  type        = string
  default     = "STRICT"
}

variable "tags" {
  description = "Additional tags applied to Verified Permissions resources"
  type        = map(string)
  default     = {}
}
