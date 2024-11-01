# Databricks notebook source
# MAGIC %md
# MAGIC # Load taxi data from SQL
# MAGIC Takes the taxi data and loads it via jdbc

# Create widgets for each parameter
dbutils.widgets.text("jdbc_hostname", "", "JDBC Hostname")
dbutils.widgets.text("jdbc_port", "1433", "JDBC Port")
dbutils.widgets.text("jdbc_database", "", "JDBC Database")
dbutils.widgets.text("jdbc_username", "", "JDBC Username")
dbutils.widgets.text("jdbc_password", "", "JDBC Password")
dbutils.widgets.text("table_name", "", "Table Name")
dbutils.widgets.text("delta_table_name", "", "Delta Table Name")

# COMMAND ----------

# Import necessary libraries
import pandas as pd

# JDBC connection parameters
jdbc_hostname = dbutils.widgets.get("jdbc_hostname")
jdbc_port = dbutils.widgets.get("jdbc_port") 
jdbc_database = dbutils.widgets.get("jdbc_database")
jdbc_username = dbutils.widgets.get("jdbc_username")
jdbc_password = dbutils.widgets.get("jdbc_password")  

# Table names
table_name = dbutils.widgets.get("table_name")
delta_table_name = dbutils.widgets.get("delta_table_name")

# Define properties for the JDBC connection
jdbc_url = f"jdbc:sqlserver://{jdbc_hostname}:{jdbc_port};databaseName={jdbc_database}"
connection_properties = {
    "user": jdbc_username,
    "password": jdbc_password,
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

# Read data from SQL Server
query = f"(SELECT * FROM {table_name}) AS source"  # SQL query to pull data
df = spark.read.jdbc(url=jdbc_url, table=query, properties=connection_properties)

# Show the dataframe
df.show()

# Write the DataFrame to a Delta table in Databricks
df.write.format("delta").mode("overwrite").saveAsTable(delta_table_name)

print(f"Data from {table_name} has been written to Delta table {delta_table_name}.")