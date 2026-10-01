output "catalog_name" {
  value = databricks_catalog.this.name
}

output "schemas" {
  value = { for k, s in databricks_schema.layer : k => s.id }
}
