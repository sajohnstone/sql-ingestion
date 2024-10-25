# sql-ingestion
This repository explores various methods for ingesting six million rows of data from SQL Server into Databricks. While the example uses Azure SQL for convenience, these approaches can be applied to other databases like PostgreSQL or MySQL. The methods covered include:

 - CDC (Change Data Capture): Leveraging CDC in Azure Data Factory to stream incremental changes into Databricks.
 - Streaming: Using a streaming approach to continuously ingest data into Databricks.
 - MERGE INTO: Utilizing the MERGE INTO command with the JDBC driver (note: not recommended for large-scale operations).
 - Snapshotting: Performing a full snapshot of data for a specific day (partitioned).
 - Using DTL: 

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



## Requirements
For using the ODBC you might need to install it
```bash
brew install unixodbc
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
brew install msodbcsql17
```

## Getting the data
I am using the classic NYC taxi dataset as it contains plenty of rows (https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers).  To get started download this to the ./data folder.

# Links
- https://www.databricks.com/discover/pages/getting-started-with-delta-live-tables
- https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers