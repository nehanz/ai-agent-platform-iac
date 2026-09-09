variable "aws_region" {
    type = string
    description = "AWS AWS region targeted for local Floci emulation"
    default = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "local"
}

variable "project_name" {
  type        = string
  description = "Base project name for resource naming and tagging"
  default     = "ai-agent-platform"
}