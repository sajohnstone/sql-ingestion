locals {
  schema_columns = [
    {
      name        = "__$start_lsn"
      type        = "Byte[]"
      description = "Log sequence number at the start of the change"
    },
    {
      name        = "__$seqval"
      type        = "Byte[]"
      description = "Sequence value for the change"
    },
    {
      name        = "__$operation"
      type        = "Int32"
      description = "Type of operation: Insert, Update, Delete"
    },
    {
      name        = "__$update_mask"
      type        = "Byte[]"
      description = "Mask for the updated columns"
    },
    {
      name        = "VendorID"
      type        = "Int32"
      description = "ID of the vendor"
    },
    {
      name        = "tpep_pickup_datetime"
      type        = "DateTime"
      description = "Pickup date and time"
    },
    {
      name        = "tpep_dropoff_datetime"
      type        = "DateTime"
      description = "Drop-off date and time"
    },
    {
      name        = "passenger_count"
      type        = "Int32"
      description = "Number of passengers"
    },
    {
      name        = "trip_distance"
      type        = "Double"
      description = "Distance of the trip in miles"
    },
    {
      name        = "RatecodeID"
      type        = "Int32"
      description = "Rate code for the trip"
    },
    {
      name        = "store_and_fwd_flag"
      type        = "String"
      description = "Flag indicating if the trip was stored and forwarded"
    },
    {
      name        = "PULocationID"
      type        = "Int32"
      description = "Pickup location ID"
    },
    {
      name        = "DOLocationID"
      type        = "Int32"
      description = "Drop-off location ID"
    },
    {
      name        = "payment_type"
      type        = "Int32"
      description = "Payment type for the trip"
    },
    {
      name        = "fare_amount"
      type        = "Double"
      description = "Fare amount for the trip"
    },
    {
      name        = "extra"
      type        = "Double"
      description = "Extra charges for the trip"
    },
    {
      name        = "mta_tax"
      type        = "Double"
      description = "MTA tax for the trip"
    },
    {
      name        = "tip_amount"
      type        = "Double"
      description = "Tip amount for the trip"
    },
    {
      name        = "tolls_amount"
      type        = "Double"
      description = "Tolls amount for the trip"
    },
    {
      name        = "improvement_surcharge"
      type        = "Double"
      description = "Improvement surcharge for the trip"
    },
    {
      name        = "total_amount"
      type        = "Double"
      description = "Total amount for the trip"
    },
    {
      name        = "congestion_surcharge"
      type        = "Double"
      description = "Congestion surcharge for the trip"
    },
    {
      name        = "ChangeDate"
      type        = "DateTime"
      description = "Date of change, defaults to current date"
    }
  ]
}

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


resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "storage" {
  name                 = "${local.name}-adls-link"
  data_factory_id      = azurerm_data_factory.this.id

  # Use managed identity for authentication
  use_managed_identity = true
  url                  = azurerm_storage_account.this.primary_dfs_endpoint
}

resource "azurerm_data_factory_dataset_sql_server_table" "source_dataset" {
  name                = "${local.short_name}_taxi_sql"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name
  table_name          = "dbo_TaxiData_CT"

  dynamic "schema_column" {
    for_each = local.schema_columns

    content {
      name        = schema_column.value.name
      type        = lookup(schema_column.value, "type", null)
      description = lookup(schema_column.value, "description", null)
    }
  }
}

resource "azurerm_data_factory_dataset_parquet" "sink_parquet" {
  name                =  "${local.short_name}_taxi_parquet"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.storage.name
  compression_codec   = "snappy"

  azure_blob_storage_location {
    container = azurerm_storage_container.this.name
    path      = "taxi"
    filename  = "@concat(utcNow(),'.parquet')"
}
}