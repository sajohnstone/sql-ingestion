resource "azurerm_resource_group" "this" {
  name     = local.name
  location = local.location
}
