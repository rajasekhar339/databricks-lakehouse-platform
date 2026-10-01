module "naming" {
  source        = "../../modules/naming"
  prefix        = var.prefix
  environment   = var.environment
  unique_suffix = var.unique_suffix
}

locals {
  tags = merge(var.tags, {
    environment = var.environment
    platform    = "databricks-lakehouse"
    managed_by  = "terraform"
  })

  containers = ["landing", "managed", "bronze", "silver", "gold"]
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group
  location = var.location
  tags     = local.tags
}

resource "azurerm_databricks_workspace" "this" {
  name                          = module.naming.workspace
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  sku                           = "premium"
  managed_resource_group_name   = module.naming.managed_resource_group
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = local.tags
}

resource "azurerm_databricks_access_connector" "this" {
  name                = module.naming.access_connector
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "lake" {
  name                            = module.naming.storage_account
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = var.environment == "prod" ? "ZRS" : "LRS"
  account_kind                    = "StorageV2"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false
  tags                            = local.tags

  blob_properties {
    delete_retention_policy {
      days = var.environment == "prod" ? 30 : 7
    }
  }
}

resource "azurerm_storage_container" "lake" {
  for_each              = toset(local.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.lake.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "connector_storage" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_key_vault" "this" {
  name                       = module.naming.key_vault
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 30
  tags                       = local.tags
}

# AzureDatabricks first-party app needs to read the vault for key vault backed scopes
data "azuread_service_principal" "azure_databricks" {
  client_id = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"
}

resource "azurerm_role_assignment" "databricks_kv_reader" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_service_principal.azure_databricks.object_id
}

resource "databricks_metastore_assignment" "this" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  metastore_id = var.metastore_id
}

data "databricks_group" "users" {
  provider     = databricks.account
  for_each     = toset(var.workspace_user_groups)
  display_name = each.key
}

data "databricks_group" "admins" {
  provider     = databricks.account
  for_each     = toset(var.workspace_admin_groups)
  display_name = each.key
}

resource "databricks_mws_permission_assignment" "users" {
  provider     = databricks.account
  for_each     = data.databricks_group.users
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  principal_id = each.value.id
  permissions  = ["USER"]
  depends_on   = [databricks_metastore_assignment.this]
}

resource "databricks_mws_permission_assignment" "admins" {
  provider     = databricks.account
  for_each     = data.databricks_group.admins
  workspace_id = azurerm_databricks_workspace.this.workspace_id
  principal_id = each.value.id
  permissions  = ["ADMIN"]
  depends_on   = [databricks_metastore_assignment.this]
}
