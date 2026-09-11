# ─── Verified Permissions Policy Store ─────────────────────────────────────────
# Central authorization repository using Cedar policy language for fine-grained
# tenant, agent, and tool permission evaluation.
resource "aws_verifiedpermissions_policy_store" "this" {
  description = var.description

  validation_settings {
    mode = var.validation_mode
  }
}

# ─── Cedar Schema Definition ──────────────────────────────────────────────────
# Defines the entity hierarchy (Tenants, Agents, Tools) and allowed actions.
# Enforces strict typing so policies cannot reference non-existent entity types or actions.
resource "aws_verifiedpermissions_schema" "this" {
  policy_store_id = aws_verifiedpermissions_policy_store.this.id

  definition {
    value = jsonencode({
      "AIAgentPlatform" = {
        entityTypes = {
          Tenant = {
            shape = {
              type       = "Record"
              attributes = {
                status = { type = "String" }
              }
            }
          }
          Agent = {
            memberOfTypes = ["Tenant"]
            shape = {
              type       = "Record"
              attributes = {
                tenant_id = { type = "String" }
                role      = { type = "String" }
              }
            }
          }
          Tool = {
            memberOfTypes = ["Tenant"]
            shape = {
              type       = "Record"
              attributes = {
                tenant_id = { type = "String" }
                tool_type = { type = "String" }
              }
            }
          }
        }
        actions = {
          InvokeTool = {
            appliesTo = {
              principalTypes = ["Agent"]
              resourceTypes  = ["Tool"]
            }
          }
          ExecutePlan = {
            appliesTo = {
              principalTypes = ["Agent"]
              resourceTypes  = ["Tenant"]
            }
          }
        }
      }
    })
  }
}

# ─── Tenant Isolation Authorization Policy ────────────────────────────────────
# Static Cedar policy: An agent can only invoke a tool if both the agent
# and the tool belong to the exact same tenant.
resource "aws_verifiedpermissions_policy" "tenant_isolation_policy" {
  policy_store_id = aws_verifiedpermissions_policy_store.this.id

  definition {
    static {
      description = "Enforce tenant boundary: agents can only invoke tools in their own tenant"
      statement   = "permit(principal, action == AIAgentPlatform::Action::\"InvokeTool\", resource) when { principal.tenant_id == resource.tenant_id };"
    }
  }

  depends_on = [
    aws_verifiedpermissions_schema.this
  ]
}
