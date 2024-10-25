# Databricks notebook source
# MAGIC %md
# MAGIC # Init notebook
# MAGIC The purpose of this notebook it to provide some of the basic functionality for the jobs 

# COMMAND ----------

#Global variables
IS_SETUP_DONE = False
CATALOG_NAME = "stu_sandbox"

# COMMAND ----------

# DBTITLE 1,able
schemas = [
    {"name": "bronze", "tables": ["taxi_data_cdc", "taxi_data_snapshot"]},
    {"name": "silver", "tables": []},
    {"name": "gold", "tables": []}
]

def get_paths(table_name):
    """Return the source path and schema location based on the table."""
    setup_catalog_and_schemas()
    for schema in schemas:
        schema_name = schema["name"]
        if table_name in schema["tables"]:
            source_path = f"abfss://taxi-data@stusqlingestdevstore.dfs.core.windows.net/{table_name}/"
            schema_location = f"abfss://taxi-data@stusqlingestdevstore.dfs.core.windows.net/{table_name}/schema/"
            checkpoint_location = f"/Volumes/{CATALOG_NAME}/{schema_name}/checkpoints/{table_name}"
            return source_path, schema_location, CATALOG_NAME, checkpoint_location
    raise ValueError(f"Unknown table: {table_name}")

def setup_catalog_and_schemas():
    global IS_SETUP_DONE

    if not IS_SETUP_DONE:
        # Create the schemas if they don't exist
        for schema in schemas:
            schema_name = schema["name"]
            spark.sql(f"CREATE SCHEMA IF NOT EXISTS {CATALOG_NAME}.{schema_name}")
            print(f"Schema '{schema_name}' created in catalog '{CATALOG_NAME}'.")
            spark.sql(f"CREATE VOLUME IF NOT EXISTS {CATALOG_NAME}.{schema_name}.checkpoints")
            print(f"Volume '{CATALOG_NAME}.{schema_name}.checkpoints' created in catalog '{CATALOG_NAME}'.")
        IS_SETUP_DONE = True
        print("Catalog and schemas setup completed.")
    else:
        print("Catalog and schemas have already been set up.")
    return schemas
