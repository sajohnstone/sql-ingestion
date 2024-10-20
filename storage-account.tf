resource "azurerm_storage_account" "this" {
  name                     = "${local.short_name}store"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}