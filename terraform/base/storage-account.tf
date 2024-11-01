resource "azurerm_storage_account" "this" {
  name                       = "${var.short_name}store"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2" 
  https_traffic_only_enabled = true   
  is_hns_enabled             = true 
}

resource "azurerm_storage_container" "this" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
