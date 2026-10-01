module "naming" {
  source        = "../../modules/naming"
  prefix        = var.prefix
  environment   = var.environment
  unique_suffix = var.unique_suffix
}

# look up foundation resources by name instead of reading the other state file
data "azurerm_databricks_workspace" "this" {
  name                = module.naming.workspace
  resource_group_name = module.naming.resource_group
}

data "azurerm_databricks_access_connector" "this" {
  name                = module.naming.access_connector
  resource_group_name = module.naming.resource_group
}

data "azurerm_key_vault" "this" {
  name                = module.naming.key_vault
  resource_group_name = module.naming.resource_group
}

module "unity_catalog" {
  source = "../../modules/unity_catalog"

  environment          = var.environment
  catalog_name         = module.naming.catalog
  workspace_id         = data.azurerm_databricks_workspace.this.workspace_id
  storage_account_name = module.naming.storage_account
  access_connector_id  = data.azurerm_databricks_access_connector.this.id
  catalog_grants       = var.catalog_grants
  schema_grants        = var.schema_grants
}

module "secrets" {
  source = "../../modules/secrets"

  key_vault_id  = data.azurerm_key_vault.this.id
  key_vault_uri = data.azurerm_key_vault.this.vault_uri
  readers       = concat([var.deployer_sp_application_id], var.secret_readers)
}

module "compute" {
  source = "../../modules/compute"

  environment                 = var.environment
  warehouse                   = var.warehouse
  job_policy                  = var.job_policy
  enable_interactive_clusters = var.enable_interactive_clusters
  compute_users               = var.compute_users
  deployer_sp_application_id  = var.deployer_sp_application_id
}
