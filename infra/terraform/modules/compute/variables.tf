variable "environment" {
  type = string
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
  type = bool
}

variable "compute_users" {
  type = list(string)
}

variable "deployer_sp_application_id" {
  type = string
}
