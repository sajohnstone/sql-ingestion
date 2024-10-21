resource "azurerm_data_factory_pipeline" "taxi_incremental" {
  name            = "${local.name}-taxi-incremental"
  data_factory_id = azurerm_data_factory.this.id

  activities_json = jsonencode([
    {
      "name" : "CopyDataActivity",
      "type" : "Copy",
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
      "source" : {
        "type" : "SqlSource"
      },
      "sink" : {
        "type" : "AzureDataLakeStoreSink",  # Updated for ADLS Gen2
        "format" : {
          "type" : "ParquetFormat"
        }
      }
    }
  ])
}