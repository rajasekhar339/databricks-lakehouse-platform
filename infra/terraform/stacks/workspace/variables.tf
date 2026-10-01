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

variable "deployer_sp_application_id" {
  type        = string
  description = "Application (client) ID of this environment's CI/CD service principal. Deploys and runs jobs."
}

variable "catalog_grants" {
  type        = map(list(string))
  description = "Principal => privileges on the environment catalog."
}

variable "schema_grants" {
  type        = map(map(list(string)))
  description = "Schema (bronze/silver/gold) => principal => privileges."
}

variable "secret_readers" {
  type        = list(string)
  default     = []
  description = "Groups that may READ the secret scope (the deployer SP always can)."
}

variable "warehouse" {
  type = object({
    cluster_size     = string
    min_num_clusters = number
    max_num_clusters = number
    auto_stop_mins   = number
  })
}

variable "job_policy" {
  type = object({
    allowed_node_types = list(string)
    max_workers        = number
  })
}

variable "enable_interactive_clusters" {
  type        = bool
  description = "Allow interactive (all-purpose) clusters. Typically true in dev only."
}

variable "compute_users" {
  type        = list(string)
  description = "Groups allowed to use cluster policies and the SQL warehouse."
}
