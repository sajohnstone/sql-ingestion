resource "azurerm_mssql_server" "this" {
  name                         = "${local.name}-sql-server"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "db_admin"
  administrator_login_password = var.sql_server_password

  identity {
    type = "SystemAssigned" # This is for enabling managed identity
  }
}

resource "azurerm_mssql_database" "this" {
  name        = "${local.name}-taxi"
  server_id   = azurerm_mssql_server.this.id
  sku_name    = "Basic"
  max_size_gb = 2
}

/*
resource "azurerm_private_endpoint" "this" {
  name                = "${local.name}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.this.id

  private_service_connection {
    name                           = "${local.name}-endpoint"
    private_connection_resource_id = azurerm_mssql_server.this.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}
*/