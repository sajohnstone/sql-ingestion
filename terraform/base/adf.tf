resource "azurerm_data_factory" "this" {
  name                = "${var.name}-datafactory"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "adf_blob_contributor" {
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.this.id
}

resource "azurerm_data_factory_linked_service_sql_server" "source_db" {
  name              = "${var.name}-sql-link"
  data_factory_id   = azurerm_data_factory.this.id
  connection_string = "Server=tcp:${azurerm_mssql_server.this.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.this.name};User ID=${azurerm_mssql_server.this.administrator_login};Password=${var.sql_server_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  depends_on        = [azurerm_mssql_server.this]
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "storage" {
  name                 = "${var.name}-adls-link"
  data_factory_id      = azurerm_data_factory.this.id

  # Use managed identity for authentication
  use_managed_identity = true
  url                  = azurerm_storage_account.this.primary_dfs_endpoint
}
