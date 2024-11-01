output "sql_server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "data_factory_id" {
  value = azurerm_data_factory.this.id
}

output "sql_server_database" {
  value = azurerm_mssql_database.this.name
}

output "sql_server_username" {
  value = azurerm_mssql_server.this.administrator_login
}

output "sql_server_password" {
  value     = var.sql_server_password
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "container_name" {
  value = azurerm_storage_container.this.name
}

output "storage_account_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true
  description = "The primary access key for the Azure Storage account."
}

output "external_location_url" {
  value = "abfss://${azurerm_storage_container.this.name}@${azurerm_storage_account.this.name}.dfs.core.windows.net/"
  description = "The URL for the external location in Azure Databricks."
}

output "access_connector_id" {
  value = azurerm_databricks_access_connector.this.id
  description = "The ID of the Databricks Access Connector."
}

output "pipeline_taxi_cdc_name" {
  value = azurerm_data_factory_pipeline.taxi_cdc.name
}

output "pipeline_taxi_snapshot_name" {
  value = azurerm_data_factory_pipeline.taxi_snapshot.name
}

output "pipeline_dbx_workflow_name" {
  value = azurerm_data_factory_pipeline.databricks_job_pipeline.name
}


## Save to env File
resource "local_file" "env_file" {
  content  = <<EOT
SERVER=${azurerm_mssql_server.this.fully_qualified_domain_name}
DATABASE=${azurerm_mssql_database.this.name}
USERNAME=${azurerm_mssql_server.this.administrator_login}
PASSWORD=${var.sql_server_password}
STORAGE_ACCOUNT_NAME=${azurerm_storage_account.this.name}
CONTAINER_NAME=${azurerm_storage_container.this.name}
STORAGE_ACCOUNT_KEY=${azurerm_storage_account.this.primary_access_key}
EXTERNAL_LOCATION_URL=abfss://${azurerm_storage_container.this.name}@${azurerm_storage_account.this.name}.dfs.core.windows.net/
ACCESS_CONNECTOR_ID=${azurerm_databricks_access_connector.this.id}
USER_ID=${azurerm_user_assigned_identity.this.id}

EOT
  filename = "${path.module}/${terraform.workspace}.env"
}
