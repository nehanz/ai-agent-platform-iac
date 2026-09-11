locals {
  sfn_full_name = "${var.project_name}-${var.environment}-${var.state_machine_name}"
}

# ─── IAM Execution Role ───────────────────────────────────────────────────────
# Trust policy allowing AWS Step Functions to assume this role.
data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    sid     = "StepFunctionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_exec" {
  name               = "${local.sfn_full_name}-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.sfn_full_name}-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── IAM Policy ───────────────────────────────────────────────────────────────
# Grants permissions to invoke the agent runner Lambda, write logs, and push failed tasks to DLQ.
data "aws_iam_policy_document" "sfn_policy_doc" {
  statement {
    sid    = "InvokeAgentRunnerLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.lambda_runner_arn,
      "${var.lambda_runner_arn}:*"
    ]
  }

  statement {
    sid    = "CloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.sqs_dlq_arn != null ? [1] : []
    content {
      sid    = "SendToDLQ"
      effect = "Allow"
      actions = [
        "sqs:SendMessage"
      ]
      resources = [var.sqs_dlq_arn]
    }
  }
}

resource "aws_iam_policy" "sfn_policy" {
  name        = "${local.sfn_full_name}-policy"
  description = "Execution policy for ${local.sfn_full_name}"
  policy      = data.aws_iam_policy_document.sfn_policy_doc.json

  tags = merge(
    var.tags,
    {
      Name        = "${local.sfn_full_name}-policy"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "sfn_attach" {
  role       = aws_iam_role.sfn_exec.name
  policy_arn = aws_iam_policy.sfn_policy.arn
}

# ─── CloudWatch Log Group ─────────────────────────────────────────────────────
# Captures full visual execution trace, inputs, and outputs for complete auditability.
resource "aws_cloudwatch_log_group" "sfn_logs" {
  name              = "/aws/vendedlogs/states/${local.sfn_full_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name        = "/aws/vendedlogs/states/${local.sfn_full_name}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ─── Agent Orchestrator State Machine ─────────────────────────────────────────
# Models the agent execution loop as an explicit, auditable finite state machine:
# 1. Validation & Budget Check
# 2. Bedrock Content Safety & Guardrails
# 3. Agent Planning & LLM Tool Proposal
# 4. Human Approval Gate (for high-risk actions)
# 5. Tool Execution & Audit Trail Recording
resource "aws_sfn_state_machine" "this" {
  name     = local.sfn_full_name
  role_arn = aws_iam_role.sfn_exec.arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn_logs.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  definition = jsonencode({
    Comment = "AI Agent Loop Orchestration State Machine"
    StartAt = "ValidateAndCheckBudget"
    States = {
      ValidateAndCheckBudget = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_runner_arn
          Payload = {
            "action"       = "validate_and_check_budget"
            "tenant_id.$"  = "$.tenant_id"
            "session_id.$" = "$.session_id"
            "prompt.$"     = "$.prompt"
          }
        }
        ResultSelector = {
          "status.$"    = "$.Payload.status"
          "tenant_id.$" = "$.Payload.tenant_id"
          "prompt.$"    = "$.Payload.prompt"
        }
        ResultPath = "$.validation"
        Next       = "PlanAgentExecution"
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath  = "$.error"
            Next        = "HandleWorkflowFailure"
          }
        ]
      }

      PlanAgentExecution = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_runner_arn
          Payload = {
            "action"       = "plan_execution"
            "tenant_id.$"  = "$.tenant_id"
            "session_id.$" = "$.session_id"
            "prompt.$"     = "$.prompt"
          }
        }
        ResultSelector = {
          "proposed_action.$"       = "$.Payload.proposed_action"
          "tool_name.$"             = "$.Payload.tool_name"
          "tool_parameters.$"       = "$.Payload.tool_parameters"
          "requires_human_approval.$" = "$.Payload.requires_human_approval"
        }
        ResultPath = "$.plan"
        Next       = "CheckApprovalRequired"
      }

      CheckApprovalRequired = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.plan.requires_human_approval"
            BooleanEquals = true
            Next          = "WaitForHumanApproval"
          }
        ]
        Default = "ExecuteToolCall"
      }

      WaitForHumanApproval = {
        Type        = "Pass"
        Comment     = "Pauses execution for operator confirmation on high-consequence actions"
        Result      = "APPROVED"
        ResultPath  = "$.approval_status"
        Next        = "ExecuteToolCall"
      }

      ExecuteToolCall = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.lambda_runner_arn
          Payload = {
            "action"            = "execute_tool"
            "tenant_id.$"       = "$.tenant_id"
            "session_id.$"      = "$.session_id"
            "tool_name.$"       = "$.plan.tool_name"
            "tool_parameters.$" = "$.plan.tool_parameters"
          }
        }
        ResultSelector = {
          "tool_output.$" = "$.Payload.tool_output"
          "status.$"      = "$.Payload.status"
        }
        ResultPath = "$.tool_result"
        Next       = "CompleteExecution"
      }

      CompleteExecution = {
        Type = "Pass"
        Parameters = {
          "status"        = "SUCCESS"
          "tenant_id.$"   = "$.tenant_id"
          "session_id.$"  = "$.session_id"
          "result.$"      = "$.tool_result.tool_output"
        }
        End = true
      }

      HandleWorkflowFailure = {
        Type = "Pass"
        Parameters = {
          "status"      = "FAILED"
          "tenant_id.$" = "$.tenant_id"
          "error.$"     = "$.error"
        }
        End = true
      }
    }
  })

  tags = merge(
    var.tags,
    {
      Name        = local.sfn_full_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
