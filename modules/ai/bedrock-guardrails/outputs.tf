output "guardrail_id" {
  description = "Unique identifier of the Bedrock Guardrail"
  value       = aws_bedrock_guardrail.this.guardrail_id
}

output "guardrail_arn" {
  description = "ARN of the Bedrock Guardrail"
  value       = aws_bedrock_guardrail.this.guardrail_arn
}

output "guardrail_version" {
  description = "Version number of the published Bedrock Guardrail snapshot"
  value       = aws_bedrock_guardrail_version.this.version
}
