output "catalog" {
  value = module.unity_catalog.catalog_name
}

output "sql_warehouse_id" {
  value = module.compute.sql_warehouse_id
}

output "job_cluster_policy_id" {
  value = module.compute.job_policy_id
}

output "secret_scope" {
  value = module.secrets.scope_name
}
