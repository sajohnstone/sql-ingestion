resource "azurerm_data_factory_pipeline" "sql_to_adls_pipeline" {
  name            = "${var.name}-sql-to-adls"
  data_factory_id = azurerm_data_factory.this.id
  folder          = "Internal Pipelines"

  parameters = {
    tableName  = ""
    outputPath = ""
    container  = ""
  }

  activities_json = jsonencode(
    [
      {
        "name" : "CopyDataActivity",
        "type" : "Copy",
        "dependsOn" : [],
        "policy" : {
          "retry" : 0,
          "retryIntervalInSeconds" : 30,
          "secureOutput" : false,
          "secureInput" : false
        },
        "typeProperties" : {
          "source" : {
            "type" : "SqlServerSource",
            "sqlReaderQuery" : "@{concat('SELECT * FROM ', pipeline().parameters.tableName)}",
            "queryTimeout" : "02:00:00"
          },
          "sink" : {
            "type" : "ParquetSink",
            "storeSettings" : {
              "type" : "AzureBlobFSWriteSettings",
              "copyBehavior" : "FlattenHierarchy"
            },
            "formatSettings" : {
              "type" : "ParquetWriteSettings"
            }
          },
          "enableStaging" : false
        },
        "inputs" : [
          {
            "referenceName" : azurerm_data_factory_dataset_sql_server_table.sql_source_dataset.name,
            "type" : "DatasetReference"
          }
        ],
        "outputs" : [
          {
            "referenceName" : azurerm_data_factory_dataset_parquet.adls_sink_parquet.name,
            "type" : "DatasetReference"
          }
        ]
      }
    ]
  )
}

resource "azurerm_data_factory_dataset_sql_server_table" "sql_source_dataset" {
  name                = "sql_source_dataset"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name
  table_name          = "@{pipeline().parameters.tableName}"
}

resource "azurerm_data_factory_dataset_parquet" "adls_sink_parquet" {
  name                = "adls_sink_parquet"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.storage.name
  compression_codec   = "snappy"

  azure_blob_storage_location {
    container = "@{pipeline().parameters.container}"
    path      = "@{pipeline().parameters.outputPath}"
    filename  = "@{concat(pipeline().parameters.tableName,formatDateTime(utcNow(), 'yyyy-MM-ddTHH:00:00Z'), '.parquet')}"
  }
}
