variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "guardrail_name" {
  description = "Name identifier for the Bedrock Guardrail"
  type        = string
  default     = "content-safety"
}

variable "description" {
  description = "Description for the Bedrock Guardrail"
  type        = string
  default     = "AI Agent Platform guardrail for PII anonymization, content filtering, and prompt safety"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for guardrail encryption"
  type        = string
  default     = null
}

variable "blocked_input_message" {
  description = "User-facing message returned when input prompt violates safety policies"
  type        = string
  default     = "Your request could not be processed due to safety and content policy restrictions."
}

variable "blocked_output_message" {
  description = "User-facing message returned when generated response violates safety policies"
  type        = string
  default     = "The generated response was blocked due to safety and content policy restrictions."
}

variable "tags" {
  description = "Additional tags applied to Bedrock Guardrail resources"
  type        = map(string)
  default     = {}
}
