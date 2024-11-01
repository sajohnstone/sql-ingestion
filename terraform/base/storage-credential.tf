resource "databricks_storage_credential" "my_storage_credential" {
  name = "${var.name}-storage-credential"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.this.id
    managed_identity_id = azurerm_user_assigned_identity.this.id
  }
  comment = "Storage credential for accessing ADLS Gen2 data using a managed identity"
  depends_on = [azurerm_databricks_access_connector.this, azurerm_user_assigned_identity.this]
}

resource "databricks_external_location" "my_external_location" {
  name               = "${var.name}-external-location"
  url                = "abfss://${azurerm_storage_container.this.name}@${azurerm_storage_account.this.name}.dfs.core.windows.net/"
  credential_name = databricks_storage_credential.my_storage_credential.id
  comment            = "External location for ADLS Gen2 data in Databricks"

  depends_on = [databricks_storage_credential.my_storage_credential]
}
