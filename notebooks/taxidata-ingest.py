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
