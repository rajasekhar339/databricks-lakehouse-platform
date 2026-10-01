output "sql_warehouse_id" {
  value = databricks_sql_endpoint.this.id
}

output "job_policy_id" {
  value = databricks_cluster_policy.job.id
}
