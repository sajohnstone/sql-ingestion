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

resource "azurerm_sql_firewall_rule" "allow_my_ip" {
  name                = "AllowMyIP"
  resource_group_name = azurerm_mssql_server.this.resource_group_name
  server_name         = azurerm_mssql_server.this.name
  start_ip_address    = data.http.my_ip.body
  end_ip_address      = data.http.my_ip.body
}

#Allow all azure services to reach the DB
resource "azurerm_sql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_mssql_server.this.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
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