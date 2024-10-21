resource "azurerm_data_factory" "this" {
  name                = "${local.name}-datafactory"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

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
  name              = "${local.name}-sql-link"
  data_factory_id   = azurerm_data_factory.this.id
  connection_string = "Server=tcp:${azurerm_mssql_server.this.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.this.name};User ID=${azurerm_mssql_server.this.administrator_login};Password=${var.sql_server_password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  depends_on        = [azurerm_mssql_server.this]
}

resource "azurerm_data_factory_dataset_sql_server_table" "source_dataset" {
  name                = "${local.short_name}_taxi_sql"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name
  table_name          = "dbo_TaxiData_CT"
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "storage" {
  name                 = "${local.name}-adls-link"
  data_factory_id      = azurerm_data_factory.this.id

  # Use managed identity for authentication
  use_managed_identity = true
  url                  = azurerm_storage_account.this.primary_dfs_endpoint
}

resource "azurerm_data_factory_dataset_parquet" "sink_parquet" {
  name                =  "${local.short_name}_taxi_parquet"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.storage.name
  compression_codec   = "snappy"

  azure_blob_storage_location {
    container = azurerm_storage_container.this.name
    path      = "taxi"
    filename  = "@utcNow().parquet"
}
}