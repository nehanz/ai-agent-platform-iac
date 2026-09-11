variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "state_machine_name" {
  description = "Base name for the Step Functions State Machine"
  type        = string
  default     = "agent-orchestrator"
}

variable "lambda_runner_arn" {
  description = "ARN of the Agent Runner Lambda function invoked by the state machine"
  type        = string
}

variable "sqs_dlq_arn" {
  description = "ARN of the Dead Letter Queue for failed workflow executions"
  type        = string
  default     = null
}

variable "log_retention_in_days" {
  description = "Retention period in days for State Machine execution CloudWatch logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags applied to Step Functions resources"
  type        = map(string)
  default     = {}
}
