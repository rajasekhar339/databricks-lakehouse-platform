output "workspace_url" {
  value = "https://${azurerm_databricks_workspace.this.workspace_url}"
}

output "workspace_id" {
  value = azurerm_databricks_workspace.this.workspace_id
}

output "storage_account" {
  value = azurerm_storage_account.lake.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}
