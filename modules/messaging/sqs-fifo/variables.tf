variable "queue_name" {
  type        = string
  description = "Base name for the SQS FIFO queue (suffix '.fifo' is appended automatically)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (local, dev, prod)"
  default     = "local"
}

variable "project_name" {
  type        = string
  description = "Base platform name for naming and tagging"
  default     = "ai-agent-platform"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS CMK for server-side encryption of messages at rest"
  default     = null
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "Duration (seconds) a message is hidden from other consumers after being received. Set to >= your agent's max processing time."
  default     = 300 # 5 minutes — enough time for a typical agent task
}

variable "message_retention_seconds" {
  type        = number
  description = "Duration (seconds) SQS retains unprocessed messages before deleting them"
  default     = 86400 # 24 hours
}

variable "max_receive_count" {
  type        = number
  description = "Number of times a message can be received before being moved to the Dead Letter Queue"
  default     = 3
}

variable "content_based_deduplication" {
  type        = bool
  description = "If true, SQS uses SHA-256 hash of message body to detect and discard duplicate messages within 5 minutes"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the queues"
  default     = {}
}
