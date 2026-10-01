variable "environment" {
  type = string
}

variable "catalog_name" {
  type = string
}

variable "workspace_id" {
  type        = string
  description = "Workspace the catalog is bound to. The catalog is invisible to other workspaces."
}

variable "storage_account_name" {
  type = string
}

variable "access_connector_id" {
  type = string
}

variable "catalog_grants" {
  type = map(list(string))
}

variable "schema_grants" {
  type = map(map(list(string)))
}
