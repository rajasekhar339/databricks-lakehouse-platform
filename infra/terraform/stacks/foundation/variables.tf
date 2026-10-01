variable "subscription_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "prefix" {
  type    = string
  default = "lakehouse"
}

variable "unique_suffix" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "databricks_account_id" {
  type = string
}

variable "metastore_id" {
  type        = string
  description = "Regional Unity Catalog metastore shared by all environments."
}

variable "workspace_user_groups" {
  type        = list(string)
  description = "Account-level groups (synced from Entra ID) that get USER access to the workspace."
}

variable "workspace_admin_groups" {
  type        = list(string)
  default     = []
  description = "Account-level groups that get ADMIN access to the workspace."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Set false (with Private Link) for prod hardening."
}

variable "tags" {
  type    = map(string)
  default = {}
}
