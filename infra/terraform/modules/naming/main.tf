variable "prefix" {
  type        = string
  description = "Short platform prefix, lowercase letters only."
}

variable "environment" {
  type        = string
  description = "dev, uat or prod."

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be dev, uat or prod."
  }
}

variable "unique_suffix" {
  type        = string
  description = "Short suffix that makes globally unique names (storage, key vault) unique."
}

locals {
  env_short = { dev = "dev", uat = "uat", prod = "prd" }[var.environment]
}

output "resource_group" { value = "rg-${var.prefix}-${local.env_short}" }
output "workspace" { value = "dbw-${var.prefix}-${local.env_short}" }
output "managed_resource_group" { value = "rg-${var.prefix}-${local.env_short}-dbw-managed" }
output "access_connector" { value = "dbac-${var.prefix}-${local.env_short}" }
output "storage_account" { value = substr("st${var.prefix}${local.env_short}${var.unique_suffix}", 0, 24) }
output "key_vault" { value = substr("kv-${var.prefix}-${local.env_short}-${var.unique_suffix}", 0, 24) }
output "catalog" { value = "${local.env_short == "prd" ? "prod" : local.env_short}_lakehouse" }
