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

## Save to env File
resource "local_file" "env_file" {
  content  = <<EOT
SERVER=${azurerm_mssql_server.this.name}.database.windows.net
DATABASE=${azurerm_mssql_database.this.name}
USERNAME=${azurerm_mssql_server.this.administrator_login}
PASSWORD=${var.sql_server_password}
EOT
  filename = "${path.module}/${terraform.workspace}.env"
}
