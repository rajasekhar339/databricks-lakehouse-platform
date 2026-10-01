terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

locals {
  layers     = ["bronze", "silver", "gold"]
  containers = concat(["landing", "managed"], local.layers)
}

resource "databricks_storage_credential" "this" {
  name    = "sc-lakehouse-${var.environment}"
  comment = "Managed identity for the ${var.environment} lakehouse storage account"

  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
}

resource "databricks_external_location" "this" {
  for_each        = toset(local.containers)
  name            = "el-lakehouse-${var.environment}-${each.key}"
  url             = "abfss://${each.key}@${var.storage_account_name}.dfs.core.windows.net/"
  credential_name = databricks_storage_credential.this.name
  comment         = "${each.key} container for ${var.environment}"
}

# catalog is bound to its own workspace only, so prod data is not visible from dev
resource "databricks_catalog" "this" {
  name           = var.catalog_name
  storage_root   = databricks_external_location.this["managed"].url
  isolation_mode = "ISOLATED"
  comment        = "Lakehouse catalog for ${var.environment}"

  properties = {
    environment = var.environment
  }
}

resource "databricks_workspace_binding" "catalog" {
  securable_name = databricks_catalog.this.name
  securable_type = "catalog"
  workspace_id   = var.workspace_id
}

resource "databricks_schema" "layer" {
  for_each     = toset(local.layers)
  catalog_name = databricks_catalog.this.name
  name         = each.key
  storage_root = databricks_external_location.this[each.key].url
  comment      = "${title(each.key)} layer"
}

resource "databricks_volume" "landing" {
  name             = "landing"
  catalog_name     = databricks_catalog.this.name
  schema_name      = databricks_schema.layer["bronze"].name
  volume_type      = "EXTERNAL"
  storage_location = databricks_external_location.this["landing"].url
  comment          = "Raw files dropped by source systems"
}

resource "databricks_volume" "checkpoints" {
  name         = "checkpoints"
  catalog_name = databricks_catalog.this.name
  schema_name  = databricks_schema.layer["bronze"].name
  volume_type  = "MANAGED"
}

resource "databricks_grants" "catalog" {
  catalog = databricks_catalog.this.name

  dynamic "grant" {
    for_each = var.catalog_grants
    content {
      principal  = grant.key
      privileges = grant.value
    }
  }
}

resource "databricks_grants" "schema" {
  for_each = var.schema_grants
  schema   = databricks_schema.layer[each.key].id

  dynamic "grant" {
    for_each = each.value
    content {
      principal  = grant.key
      privileges = grant.value
    }
  }
}
