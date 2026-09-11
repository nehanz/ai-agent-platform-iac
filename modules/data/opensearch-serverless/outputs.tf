output "collection_id" {
  description = "Unique identifier of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.id
}

output "collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.this.arn
}

output "collection_endpoint" {
  description = "Endpoint URL for indexing and vector search queries"
  value       = aws_opensearchserverless_collection.this.collection_endpoint
}

output "dashboard_endpoint" {
  description = "Endpoint URL for OpenSearch Dashboards"
  value       = aws_opensearchserverless_collection.this.dashboard_endpoint
}
