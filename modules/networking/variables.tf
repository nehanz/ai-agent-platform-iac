variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (e.g. load balancers, egress)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (e.g. ECS workers, Lambda, Redis)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "enable_gateway_endpoints" {
  description = "Whether to create S3 and DynamoDB VPC Gateway Endpoints for secure private communication"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all networking resources"
  type        = map(string)
  default     = {}
}
