resource "azurerm_resource_group" "this" {
  name     = local.name
  location = local.location
}

module "base" {
  source              = "./base"
  name                = local.name
  short_name          = local.short_name
  sql_server_password = var.sql_server_password
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}
