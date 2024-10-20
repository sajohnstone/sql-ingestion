resource "azurerm_data_factory" "this" {
  name                = "${local.name}-datafactory"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_factory_linked_service_sql_server" "source_db" {
  name              = "${local.name}-sql-link"
  data_factory_id   = azurerm_data_factory.this.id
  connection_string = "Server=tcp:${azurerm_mssql_server.this.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.this.name};User ID=${azurerm_mssql_server.this.administrator_login};Password=${var.sql_server_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  depends_on        = [azurerm_mssql_server.this]
}

resource "azurerm_data_factory_dataset_sql_server_table" "source_dataset" {
  name                = "${local.name}-sql-ds"
  data_factory_id   = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name
  table_name = "dbo_TaxiData_CT"
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "storage" {
  name              = "${local.name}-storageacc-link"
  data_factory_id   = azurerm_data_factory.this.id
  connection_string = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.this.name};AccountKey=<your_storage_account_key>;EndpointSuffix=core.windows.net"
}

resource "azurerm_data_factory_dataset_azure_blob" "blob_dataset" {
  name                = "${local.name}-ds"
  data_factory_id   = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.storage.name

  path     = "taxi_data_cdc"
  filename = "data.parquet"
}