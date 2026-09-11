variable "project_name" {
  description = "Project identifier used in resource naming and tags"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. local, dev, staging, prod)"
  type        = string
}

variable "collection_name" {
  description = "Name identifier for the OpenSearch Serverless collection"
  type        = string
  default     = "agent-vectors"
}

variable "description" {
  description = "Description of the OpenSearch Serverless collection"
  type        = string
  default     = "Vector database collection for agent semantic memory and RAG retrieval"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting collection data at rest"
  type        = string
  default     = null
}

variable "principal_arns" {
  description = "List of IAM principal ARNs permitted to access and query vector indices"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to OpenSearch Serverless resources"
  type        = map(string)
  default     = {}
}
