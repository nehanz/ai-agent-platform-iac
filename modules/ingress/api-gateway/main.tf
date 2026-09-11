locals {
  api_full_name = "${var.project_name}-${var.environment}-${var.api_name}"
}

# ─── HTTP API Gateway ─────────────────────────────────────────────────────────
# Inbound entrypoint for client REST requests, agent task submission, and health checks.
resource "aws_apigatewayv2_api" "http_api" {
  name          = local.api_full_name
  protocol_type = "HTTP"
  description   = "API Gateway for AI Agent Platform client requests and task submissions"

  cors_configuration {
    allow_headers = ["content-type", "authorization", "x-tenant-id"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = ["*"]
    max_age       = 300
  }

  tags = merge(
    var.tags,
    {
      Name        = local.api_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── CloudWatch Access Log Group ──────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${local.api_full_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = "/aws/apigateway/${local.api_full_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── API Gateway Stage ────────────────────────────────────────────────────────
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      responseLength = "$context.responseLength"
    })
  }

  tags = merge(
    var.tags,
    {
      Name        = "${local.api_full_name}-$default"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Lambda Integration ───────────────────────────────────────────────────────
# Routes incoming API requests directly into the serverless Lambda worker.
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_target_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# ─── API Routes ───────────────────────────────────────────────────────────────
# Task submission endpoint
resource "aws_apigatewayv2_route" "tasks" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Direct agent execution endpoint
resource "aws_apigatewayv2_route" "execute" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /agents/execute"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Health check endpoint
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# ─── Lambda Invocation Permission ─────────────────────────────────────────────
# Grants API Gateway authorization to invoke the backend Lambda function.
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_target_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
