output "bucket_id" {
  description = "The name of the S3 audit bucket (same as bucket_name)"
  value       = aws_s3_bucket.audit.id
}

output "bucket_name" {
  description = "The globally unique name of the S3 audit bucket"
  value       = aws_s3_bucket.audit.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 audit bucket (used in IAM policies for Lambda/ECS task roles)"
  value       = aws_s3_bucket.audit.arn
}

output "bucket_domain_name" {
  description = "The bucket's regional domain name for constructing S3 URLs"
  value       = aws_s3_bucket.audit.bucket_regional_domain_name
}

output "kms_key_arn" {
  description = "The KMS key ARN used for SSE-KMS encryption on this bucket"
  value       = var.kms_key_arn
}
