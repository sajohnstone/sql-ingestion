output "sql_server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "data_factory_id" {
  value = azurerm_data_factory.this.id
}

output "sql_server_server" {
  value = "${azurerm_mssql_server.this.name}.database.windows.net"
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

## Save to env File
resource "local_file" "env_file" {
  content  = <<EOT
SERVER=${azurerm_mssql_server.this.name}.database.windows.net
DATABASE=${azurerm_mssql_database.this.name}
USERNAME=${azurerm_mssql_server.this.administrator_login}
PASSWORD=${var.sql_server_password}
STORAGE_ACCOUNT_NAME=${azurerm_storage_account.this.name}
CONTAINER_NAME=${azurerm_storage_container.this.name}
EOT
  filename = "${path.module}/${terraform.workspace}.env"
}
