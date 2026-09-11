variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "api_name" {
  description = "Name identifier for the API Gateway"
  type        = string
  default     = "agent-gateway"
}

variable "lambda_target_arn" {
  description = "ARN of the Lambda function invoked by API Gateway routes"
  type        = string
}

variable "log_retention_in_days" {
  description = "Retention period in days for API Gateway access logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags applied to API Gateway resources"
  type        = map(string)
  default     = {}
}
