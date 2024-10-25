# Databricks notebook source
# MAGIC %md
# MAGIC # Load taxi data
# MAGIC Takes the taxi data and loads it

# COMMAND ----------

# MAGIC %run ./job_init

# COMMAND ----------

dbutils.widgets.text("table_name", "default_table_name", "Table Name")
dbutils.widgets.text("schema_name", "default_schema", "Schema Name")

# COMMAND ----------

"""
import re  # Import the 're' module, which provides regular expressions for string manipulation

# Define the path to the source data
path = ""  # Base path for the data (currently empty)
table_name = "taxi_data_cdc"  # Name of the table to read and write data
schema_name = "bronze"  # Schema name under which the table will be categorized

# Retrieve paths and catalog settings using the get_paths function
source_path, schema_location, catalog_name, checkpoint_location = get_paths(path, table_name)
fq_table_name = f"{catalog_name}.{schema_name}.{table_name}"  # Fully qualified table name for the output table

# Set Spark SQL configuration to ignore missing files during read
spark.conf.set("spark.sql.files.ignoreMissingFiles", "true")  # Avoid errors if files are missing

# Configure the Autoloader to read the parquet files
df = (spark.readStream
      .format("cloudFiles")
      .option("cloudFiles.format", "parquet")
      .option("cloudFiles.schemaLocation", schema_location)
      .load(source_path))
print("Data has been read..")

# Function to clean column names
def clean_column_name(col_name):
    return re.sub(r'[^a-zA-Z0-9_]', '', col_name)

# Apply the clean_column_name function to each column
for col_name in df.columns:
    df = df.withColumnRenamed(col_name, clean_column_name(col_name))

# Write the stream (or switch to batch mode if not streaming)
print("Write the stream..")
query = (df.writeStream
          .outputMode("append")
          .format("delta")
          .option("checkpointLocation", checkpoint_location)
          .option("mergeSchema", "true")
          .table(fq_table_name))

# Wait for the query to finish
query.awaitTermination()
"""

# COMMAND ----------

# Define the path to the source data
table_name = dbutils.widgets.get("table_name")
schema_name = dbutils.widgets.get("schema_name")
source_path, schema_location, catalog_name, checkpoint_location = get_paths(table_name)
fq_table_name = f"{catalog_name}.{schema_name}.{table_name}"

# Read the batch data from the specified path
df = (spark.read
      .format("parquet")
      .load(source_path))

# Write the data in batch mode
df.write.format("delta").mode("append").saveAsTable(fq_table_name)
