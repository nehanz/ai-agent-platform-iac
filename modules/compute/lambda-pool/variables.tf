variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "function_name" {
  description = "Base name for the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function purpose"
  type        = string
  default     = "AI Agent platform worker function"
}

variable "runtime" {
  description = "Lambda execution runtime"
  type        = string
  default     = "python3.11"
}

variable "handler" {
  description = "Entry point function in the code bundle"
  type        = string
  default     = "index.handler"
}

variable "memory_size" {
  description = "Amount of memory in MB allocated to the Lambda function"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 60
}

variable "environment_variables" {
  description = "Map of environment variables injected into the Lambda runtime"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Retention period in days for CloudWatch log events"
  type        = number
  default     = 14
}

variable "enable_sqs_trigger" {
  description = "Whether to configure an SQS event source mapping trigger"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to trigger this Lambda (required if enable_sqs_trigger is true)"
  type        = string
  default     = null
}

variable "sqs_batch_size" {
  description = "Maximum number of SQS records delivered in a single batch"
  type        = number
  default     = 10
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs that this Lambda has read/write permissions for"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs that this Lambda has access to send or read messages"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that this Lambda has access to read or write"
  type        = list(string)
  default     = []
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager secret ARNs that this Lambda has access to read"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs that this Lambda has permission to decrypt with or generate data keys"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to all Lambda-related resources"
  type        = map(string)
  default     = {}
}
