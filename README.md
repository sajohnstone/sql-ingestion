# sql-ingestion
How to ingest data from SQL server into Databricks.  This repo will look at a few methods of getting six million rows of data from SQL server into Databricks.  I'm using Azure SQL for ease but any SQL, Postgre, MySQL should work along the sames lines.  The methods I will be using are:-
 - CDC: Using CDC on Data Factory and letting DBX pull data from that stream
 - Streaming: Using streaming to get data into to DBX
 - MERGE INTO: Using MERGE into and the JDBC driver (note this is not recommended at scale)

## Getting the data
I am using the classic NYC taxi dataset as it contains plenty of rows (https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers).  To get started download this to the ./data folder.

# Links
- https://www.databricks.com/discover/pages/getting-started-with-delta-live-tables
- https://www.kaggle.com/datasets/diishasiing/revenue-for-cab-drivers