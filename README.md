# sql-ingestion
This repository explores various methods for ingesting data from SQL Server into Databricks. While the example uses Azure SQL for convenience, these approaches can be applied to other databases like PostgreSQL or MySQL. The methods covered include:

 - ADF > ADLS Gen2 > DBX WF: Using Azure Data Factory (ADF) to ADLS Gen2 storage account then into Databricks using a workflow
 - SQL JDBC: Connecting from Databricks via JDBC direct to SQL (obviously this required a direct connection)
 - ADF > ADLS Gen2 > DBX DLT: Using Azure Data Factory (ADF) to ADLS Gen2 storage account then into Databricks via Delta Live Tables (DLT)

 Once the data is in we will use a number of methods to move it including
 - CDC (Change Data Capture): Leveraging CDC in to provide an append only data
 - MERGE INTO: Utilizing the MERGE INTO command to merge data from one datasource into another
 - Snapshotting: Performing a full snapshot of data for a specific day (partitioned).

Each method provides different trade-offs in terms of scalability, performance, and use case suitability.

## CDC
For this we will use the CDC data and using ADF to read this data and write it to Parquet files on a storage account, then Databrick will stream or batch this in via Autoloader.

SQL >> ADF >> Storage Account >> DBX Job >> Autoloader >> Delta Table

NOTE: In this example we've used triggers to simulated CDC data.  This is in order to keep the cost for running this to a minimim.  In the real-world you can use Azure SQL with a P1 licence and enable CDC.

```sql
-- Enable CDC on the database
EXEC sys.sp_cdc_enable_db;
-- Enable CDC on a specific table
EXEC sys.sp_cdc_enable_table
    @source_schema = 'dbo',          -- Schema of the source table
    @source_name = 'YourTableName',  -- Name of the source table
    @role_name = NULL;                -- Optional role name for permissions
```

## Getting the data
I am using the classic NYC taxi dataset as it contains plenty of rows (https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers).  To get started download this to the ./data folder.

# Links
- https://www.databricks.com/discover/pages/getting-started-with-delta-live-tables
- https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers