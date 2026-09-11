variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting SNS messages at rest"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to notification resources"
  type        = map(string)
  default     = {}
}
