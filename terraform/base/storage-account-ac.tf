resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.name}-uami"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_databricks_access_connector" "this" {
  name                = "${var.name}-ac"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
}

resource "azurerm_role_assignment" "this" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
