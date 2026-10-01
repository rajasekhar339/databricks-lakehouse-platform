subscription_id            = "00000000-0000-0000-0000-00000000d001"
environment                = "dev"
prefix                     = "lakehouse"
unique_suffix              = "x7k2"
deployer_sp_application_id = "00000000-0000-0000-0000-000000000001"

catalog_grants = {
  "data-platform-engineers"              = ["ALL_PRIVILEGES"]
  "00000000-0000-0000-0000-000000000001" = ["ALL_PRIVILEGES"]
}

schema_grants = {
  gold = {
    "data-analysts" = ["USE_SCHEMA", "SELECT"]
  }
}

secret_readers = ["data-platform-engineers"]

warehouse = {
  cluster_size     = "2X-Small"
  min_num_clusters = 1
  max_num_clusters = 1
  auto_stop_mins   = 10
}

job_policy = {
  allowed_node_types = ["Standard_D4ds_v5", "Standard_D8ds_v5"]
  max_workers        = 2
}

enable_interactive_clusters = true
compute_users               = ["data-platform-engineers", "data-analysts"]
