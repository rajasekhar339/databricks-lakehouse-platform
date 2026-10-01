subscription_id            = "00000000-0000-0000-0000-00000000d003"
environment                = "prod"
prefix                     = "lakehouse"
unique_suffix              = "x7k2"
deployer_sp_application_id = "00000000-0000-0000-0000-000000000003"

catalog_grants = {
  "00000000-0000-0000-0000-000000000003" = ["ALL_PRIVILEGES"]
  "data-platform-engineers"              = ["USE_CATALOG"]
  "data-analysts"                        = ["USE_CATALOG"]
}

schema_grants = {
  silver = {
    "data-platform-engineers" = ["USE_SCHEMA", "SELECT"]
  }
  gold = {
    "data-platform-engineers" = ["USE_SCHEMA", "SELECT"]
    "data-analysts"           = ["USE_SCHEMA", "SELECT"]
  }
}

secret_readers = []

warehouse = {
  cluster_size     = "Small"
  min_num_clusters = 1
  max_num_clusters = 4
  auto_stop_mins   = 15
}

job_policy = {
  allowed_node_types = ["Standard_D8ds_v5", "Standard_D16ds_v5"]
  max_workers        = 8
}

enable_interactive_clusters = false
compute_users               = ["data-analysts"]
