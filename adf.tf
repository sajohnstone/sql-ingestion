resource "azurerm_data_factory" "this" {
  name                = "${local.name}-datafactory"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }
}
