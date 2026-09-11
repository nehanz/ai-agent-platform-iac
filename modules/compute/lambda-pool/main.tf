locals {
  function_full_name = "${var.project_name}-${var.environment}-${var.function_name}"
}

# ─── Lambda Code Packaging ───────────────────────────────────────────────────
# Bundles the source code directory into a zip archive for Lambda deployment.
# Computes the source code SHA256 hash so Terraform detects code changes and triggers updates.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/dist/function.zip"
}



# ─── IAM Execution Role ───────────────────────────────────────────────────────
# Trust policy allowing the AWS Lambda service to assume this role.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.function_full_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.function_full_name}-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── IAM Least-Privilege Policy ───────────────────────────────────────────────
# Combines permissions for CloudWatch Logs, DynamoDB tables, SQS queues,
# S3 storage, Secrets Manager, and KMS decryption based on input variables.
data "aws_iam_policy_document" "lambda_permissions" {
  # CloudWatch Logging permissions
  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${local.function_full_name}:*"
    ]
  }

  # DynamoDB permissions (conditional on provided table ARNs)
  dynamic "statement" {
    for_each = length(var.dynamodb_table_arns) > 0 ? [1] : []
    content {
      sid    = "DynamoDBTableAccess"
      effect = "Allow"
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem"
      ]
      resources = flatten([
        for arn in var.dynamodb_table_arns : [
          arn,
          "${arn}/index/*"
        ]
      ])
    }
  }

  # SQS permissions (conditional on provided queue ARNs)
  dynamic "statement" {
    for_each = length(var.sqs_queue_arns) > 0 ? [1] : []
    content {
      sid    = "SQSQueueAccess"
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:SendMessage",
        "sqs:ChangeMessageVisibility"
      ]
      resources = var.sqs_queue_arns
    }
  }

  # S3 permissions (conditional on provided bucket ARNs)
  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []
    content {
      sid    = "S3BucketAccess"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      resources = flatten([
        for arn in var.s3_bucket_arns : [
          arn,
          "${arn}/*"
        ]
      ])
    }
  }

  # Secrets Manager permissions (conditional on secret ARNs)
  dynamic "statement" {
    for_each = length(var.secrets_manager_arns) > 0 ? [1] : []
    content {
      sid    = "SecretsManagerAccess"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = var.secrets_manager_arns
    }
  }

  # KMS decryption permissions (conditional on KMS key ARNs)
  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid    = "KMSDecryptionAccess"
      effect = "Allow"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*"
      ]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${local.function_full_name}-policy"
  description = "Least privilege IAM policy for ${local.function_full_name}"
  policy      = data.aws_iam_policy_document.lambda_permissions.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.function_full_name}-policy"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# ─── CloudWatch Log Group ─────────────────────────────────────────────────────
# Explicit log group creation with retention setting prevents indefinite log storage costs.
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.function_full_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = "/aws/lambda/${local.function_full_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Lambda Function ──────────────────────────────────────────────────────────
# Worker compute instance configured with environment variables, IAM role, and runtime timeout.
resource "aws_lambda_function" "function" {
  function_name    = local.function_full_name
  description      = var.description
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_attach,
    aws_cloudwatch_log_group.lambda_logs
  ]

  tags = merge(
    var.tags,
    {
      Name        = local.function_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── SQS Event Source Mapping ─────────────────────────────────────────────────
# Connects an SQS queue to trigger the Lambda function automatically for task polling.
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count            = var.enable_sqs_trigger && var.sqs_queue_arn != null ? 1 : 0
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.function.arn
  batch_size       = var.sqs_batch_size
  enabled          = true
}
