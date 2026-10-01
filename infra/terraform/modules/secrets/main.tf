terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

variable "scope_name" {
  type        = string
  default     = "kv-lakehouse"
  description = "Same name in every workspace so code is environment-agnostic."
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}

variable "readers" {
  type        = list(string)
  description = "Group names or service principal application IDs with READ on the scope."
}

# values are added directly in key vault, terraform never sees them
resource "databricks_secret_scope" "this" {
  name = var.scope_name

  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.key_vault_uri
  }
}

resource "databricks_secret_acl" "readers" {
  for_each   = toset(var.readers)
  scope      = databricks_secret_scope.this.name
  principal  = each.key
  permission = "READ"
}

output "scope_name" {
  value = databricks_secret_scope.this.name
}
