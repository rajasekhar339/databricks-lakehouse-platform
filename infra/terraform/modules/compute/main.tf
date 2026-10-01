terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

locals {
  common_tags = {
    "custom_tags.environment" = { type = "fixed", value = var.environment }
    "custom_tags.cost_center" = { type = "fixed", value = "data-platform" }
  }

  node_types = {
    "node_type_id"        = { type = "allowlist", values = var.job_policy.allowed_node_types }
    "driver_node_type_id" = { type = "allowlist", values = var.job_policy.allowed_node_types }
  }
}

# policy + warehouse names are the same in every workspace so the bundle can look them up
resource "databricks_cluster_policy" "job" {
  name = "lakehouse-job-compute"
  definition = jsonencode(merge(local.common_tags, local.node_types, {
    "cluster_type"          = { type = "fixed", value = "job" }
    "spark_version"         = { type = "regex", pattern = "^1[5-9]\\.[0-9]+\\.x-.*" }
    "data_security_mode"    = { type = "allowlist", values = ["SINGLE_USER", "USER_ISOLATION"] }
    "autoscale.max_workers" = { type = "range", maxValue = var.job_policy.max_workers, defaultValue = 2 }
    "azure_attributes.availability" = {
      type  = "fixed"
      value = var.environment == "prod" ? "ON_DEMAND_AZURE" : "SPOT_WITH_FALLBACK_AZURE"
    }
  }))
}

resource "databricks_cluster_policy" "interactive" {
  count = var.enable_interactive_clusters ? 1 : 0
  name  = "lakehouse-interactive"
  definition = jsonencode(merge(local.common_tags, local.node_types, {
    "cluster_type"            = { type = "fixed", value = "all-purpose" }
    "data_security_mode"      = { type = "fixed", value = "USER_ISOLATION" }
    "autotermination_minutes" = { type = "range", maxValue = 60, defaultValue = 30 }
    "autoscale.max_workers"   = { type = "range", maxValue = 4, defaultValue = 2 }
  }))
}

resource "databricks_permissions" "job_policy" {
  cluster_policy_id = databricks_cluster_policy.job.id

  access_control {
    service_principal_name = var.deployer_sp_application_id
    permission_level       = "CAN_USE"
  }

  dynamic "access_control" {
    for_each = toset(var.compute_users)
    content {
      group_name       = access_control.value
      permission_level = "CAN_USE"
    }
  }
}

resource "databricks_permissions" "interactive_policy" {
  count             = var.enable_interactive_clusters ? 1 : 0
  cluster_policy_id = databricks_cluster_policy.interactive[0].id

  dynamic "access_control" {
    for_each = toset(var.compute_users)
    content {
      group_name       = access_control.value
      permission_level = "CAN_USE"
    }
  }
}

resource "databricks_sql_endpoint" "this" {
  name                      = "wh-lakehouse"
  cluster_size              = var.warehouse.cluster_size
  min_num_clusters          = var.warehouse.min_num_clusters
  max_num_clusters          = var.warehouse.max_num_clusters
  auto_stop_mins            = var.warehouse.auto_stop_mins
  enable_serverless_compute = true
  warehouse_type            = "PRO"

  tags {
    custom_tags {
      key   = "environment"
      value = var.environment
    }
    custom_tags {
      key   = "cost_center"
      value = "data-platform"
    }
  }
}

resource "databricks_permissions" "warehouse" {
  sql_endpoint_id = databricks_sql_endpoint.this.id

  access_control {
    service_principal_name = var.deployer_sp_application_id
    permission_level       = "CAN_MANAGE"
  }

  dynamic "access_control" {
    for_each = toset(var.compute_users)
    content {
      group_name       = access_control.value
      permission_level = "CAN_USE"
    }
  }
}
