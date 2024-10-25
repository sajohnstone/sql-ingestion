provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

provider "databricks" {
  host     = var.workspace_url
  token    = var.workspace_token
}
