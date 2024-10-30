locals {
  cdc_schema_columns = [
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

resource "azurerm_data_factory_pipeline" "taxi_cdc" {
  name            = "${local.name}-taxi-cdc"
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
            "referenceName" : azurerm_data_factory_dataset_sql_server_table.cdc_source_dataset.name,
            "type" : "DatasetReference"
          }
        ],
        "outputs" : [
          {
            "referenceName" : azurerm_data_factory_dataset_parquet.cdc_sink_parquet.name,
            "type" : "DatasetReference"
          }
        ]
      },
      {
        "name" : "Start Workflow",
        "type" : "ExecutePipeline",
        "dependsOn" : [
          {
            "activity" : "CopyDataActivity",
            "dependencyConditions" : [
              "Succeeded"
            ]
          }
        ],
        "policy" : {
          "secureInput" : false
        },
        "userProperties" : [],
        "typeProperties" : {
          "pipeline" : {
            "referenceName" : azurerm_data_factory_pipeline.databricks_job_pipeline.name,
            "type" : "PipelineReference"
          },
          "waitOnCompletion" : true,
          "parameters" : {
            "DatabricksWorkspaceID" : local.workspace_id,
            "JobID" : databricks_job.taxidata_ingestion_cdc.id,
            "WaitSeconds" : "60"
          }
        }
      }
    ]
  )

  depends_on = [ databricks_job.taxidata_ingestion_cdc ]
}
resource "azurerm_data_factory_dataset_sql_server_table" "cdc_source_dataset" {
  name                = "${local.short_name}_dbo_taxidata_ct"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name
  table_name          = "dbo_TaxiData_CT"

  dynamic "schema_column" {
    for_each = local.cdc_schema_columns

    content {
      name        = schema_column.value.name
      type        = lookup(schema_column.value, "type", null)
      description = lookup(schema_column.value, "description", null)
    }
  }
}

resource "azurerm_data_factory_dataset_parquet" "cdc_sink_parquet" {
  name                = "${local.short_name}_taxidata_ct"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.storage.name
  compression_codec   = "snappy"

  azure_blob_storage_location {
    container = azurerm_storage_container.this.name
    path      = "taxi_data_cdc"
    filename  = "@concat('taxi_data','.parquet')"
  }
}
