resource "azurerm_storage_account" "this" {
  name                       = "${local.short_name}store"
  resource_group_name        = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2" 
  https_traffic_only_enabled = true   
  is_hns_enabled             = true        # Enable hierarchical namespace for ADLS Gen2
}

resource "azurerm_storage_container" "this" {
  name                  = "taxi-data"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
