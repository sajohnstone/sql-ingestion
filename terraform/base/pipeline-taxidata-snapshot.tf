locals {
  schema_columns = [
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
      name        = "current_sync_date"
      type        = "DateTime"
      description = "The date of the current sync"
    }
  ]
}

resource "azurerm_data_factory_pipeline" "taxi_snapshot" {
  name            = "${var.name}-base-taxi-snapshot-copydata"
  data_factory_id = azurerm_data_factory.this.id

  activities_json = jsonencode(
    [
      {
        "name": "CopyDataActivity",
        "type": "Copy",
        "dependsOn": [],
        "policy": {
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
        },
        "userProperties": [],
        "typeProperties": {
          "source": {
            "type": "SqlServerSource",
            "sqlReaderQuery": <<SQL
              SELECT 
                VendorID,
                tpep_pickup_datetime,
                tpep_dropoff_datetime,
                passenger_count,
                trip_distance,
                RatecodeID,
                store_and_fwd_flag,
                PULocationID,
                DOLocationID,
                payment_type,
                fare_amount,
                extra,
                mta_tax,
                tip_amount,
                tolls_amount,
                improvement_surcharge,
                total_amount,
                congestion_surcharge,
                GETUTCDATE() AS current_sync_date -- Hardcoded current date in the query
              FROM TaxiData;
            SQL
            "queryTimeout": "02:00:00",
            "partitionOption": "None"
          },
          "sink": {
            "type": "ParquetSink",
            "storeSettings": {
              "type": "AzureBlobFSWriteSettings",
              "copyBehavior": "FlattenHierarchy"
            },
            "formatSettings": {
              "type": "ParquetWriteSettings"
            }
          },
          "enableStaging": false
        },
        "inputs": [
          {
            "referenceName": azurerm_data_factory_dataset_sql_server_table.snapshot_source_dataset.name,
            "type": "DatasetReference"
          }
        ],
        "outputs": [
          {
            "referenceName": azurerm_data_factory_dataset_parquet.snapshot_sink_parquet.name,
            "type": "DatasetReference"
          }
        ]
      }
    ]
  )
}

resource "azurerm_data_factory_dataset_sql_server_table" "snapshot_source_dataset" {
  name                = "${var.short_name}_dbo_taxidata"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.source_db.name

  # We use a query instead of table_name here
  parameters = {
    SourceQuery = <<QUERY
      SELECT 
        VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        RatecodeID,
        store_and_fwd_flag,
        PULocationID,
        DOLocationID,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        GETUTCDATE() AS current_sync_date -- Add the current date in the query
      FROM TaxiData;
    QUERY
  }
}

resource "azurerm_data_factory_dataset_parquet" "snapshot_sink_parquet" {
  name                = "${var.short_name}_taxidata_snapshot"
  data_factory_id     = azurerm_data_factory.this.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.storage.name
  compression_codec   = "snappy"

  azure_blob_storage_location {
    container = azurerm_storage_container.this.name
    path      = "taxi_data_snapshot"
    filename  = "@concat(utcNow(),'.parquet')"
  }
}
