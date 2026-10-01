subscription_id            = "00000000-0000-0000-0000-00000000d002"
environment                = "uat"
prefix                     = "lakehouse"
unique_suffix              = "x7k2"
deployer_sp_application_id = "00000000-0000-0000-0000-000000000002"

catalog_grants = {
  "00000000-0000-0000-0000-000000000002" = ["ALL_PRIVILEGES"]
  "data-platform-engineers"              = ["USE_CATALOG", "USE_SCHEMA", "SELECT", "READ_VOLUME"]
}

schema_grants = {
  gold = {
    "data-analysts" = ["USE_SCHEMA", "SELECT"]
  }
}

secret_readers = []

warehouse = {
  cluster_size     = "X-Small"
  min_num_clusters = 1
  max_num_clusters = 2
  auto_stop_mins   = 10
}

job_policy = {
  allowed_node_types = ["Standard_D4ds_v5", "Standard_D8ds_v5"]
  max_workers        = 4
}

enable_interactive_clusters = false
compute_users               = ["data-platform-engineers", "data-analysts"]
