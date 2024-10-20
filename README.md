# sql-ingestion
How to ingest data from SQL server into Databricks.  This repo will look at a few methods of getting six million rows of data from SQL server into Databricks.  I'm using Azure SQL for ease but any SQL, Postgre, MySQL should work along the sames lines.  The methods I will be using are:-
 - CDC: Using CDC on Data Factory and letting DBX pull data from that stream
 - Streaming: Using streaming to get data into to DBX
 - MERGE INTO: Using MERGE into and the JDBC driver (note this is not recommended at scale)


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