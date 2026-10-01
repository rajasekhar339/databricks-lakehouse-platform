terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.50"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "databricks" {
  host                        = "https://${data.azurerm_databricks_workspace.this.workspace_url}"
  azure_workspace_resource_id = data.azurerm_databricks_workspace.this.id
}
