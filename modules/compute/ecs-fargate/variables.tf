variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster for agent workloads"
  type        = string
  default     = "agent-workers"
}

variable "service_name" {
  description = "Name of the ECS service and task family"
  type        = string
  default     = "agent-worker"
}

variable "container_image" {
  description = "Container image URL for the agent worker container"
  type        = string
  default     = "public.ecr.aws/docker/library/python:3.11-slim"
}

variable "cpu" {
  description = "Amount of CPU units allocated to the task (e.g. 256, 512, 1024)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Amount of memory in MB allocated to the task (e.g. 512, 1024, 2048)"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Number of simultaneous container instances to run in the ECS service"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs where ECS tasks will run"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs associated with the ECS tasks"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to the ECS task ENIs"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Key-value map of environment variables passed into the container"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Retention period in days for ECS container CloudWatch log events"
  type        = number
  default     = 14
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs that the agent worker task can access"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "List of SQS queue ARNs that the agent worker task can poll or send messages to"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that the agent worker task can read or write to"
  type        = list(string)
  default     = []
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager secret ARNs that the agent worker task can retrieve"
  type        = list(string)
  default     = []
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs that the agent worker task can use for decryption"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to all ECS resources"
  type        = map(string)
  default     = {}
}
