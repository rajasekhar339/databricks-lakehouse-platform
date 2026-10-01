subscription_id       = "00000000-0000-0000-0000-00000000d003"
environment           = "prod"
prefix                = "lakehouse"
unique_suffix         = "x7k2"
location              = "westeurope"
databricks_account_id = "00000000-0000-0000-0000-00000000acc1"
metastore_id          = "00000000-0000-0000-0000-00000000aaaa"

workspace_user_groups  = ["data-platform-engineers", "data-analysts"]
workspace_admin_groups = []

public_network_access_enabled = true

tags = {
  owner = "data-platform-team"
}
