resource "azurerm_data_factory_pipeline" "taxi_incremental" {
  name            = "${local.name}-taxi-incremental"
  data_factory_id = azurerm_data_factory.this.id

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
        "userProperties" : [],
        "typeProperties" : {
          "source" : {
            "type" : "SqlServerSource",
            "queryTimeout" : "02:00:00",
            "partitionOption" : "None"
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
            "referenceName" : azurerm_data_factory_dataset_sql_server_table.source_dataset.name,
            "type" : "DatasetReference"
          }
        ],
        "outputs" : [
          {
            "referenceName" : azurerm_data_factory_dataset_parquet.sink_parquet.name,
            "type" : "DatasetReference"
          }
        ],
        "sink" : {
          "format" : {
            "type" : "ParquetFormat"
          },
          "type" : "AzureDataLakeStoreSink"
        },
        "source" : {
          "type" : "SqlSource"
        }
      }
  ])
}




