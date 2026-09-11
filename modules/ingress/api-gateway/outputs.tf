output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  description = "Base URL of the API Gateway endpoint for client requests"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.execution_arn
}

output "stage_name" {
  description = "Deployed stage name"
  value       = aws_apigatewayv2_stage.default.name
}
