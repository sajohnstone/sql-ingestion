# Import necessary libraries for Delta Live Tables
import dlt
from pyspark.sql.functions import *

# Define widget parameters for DLT pipeline configuration
table_name = spark.conf.get("table_name", "default_table_name")
container_name = spark.conf.get("container_name", "default_container_name")
storage_account = spark.conf.get("storage_account", "default_storage_account")

# Define paths for source data and Delta table
source_path = (
    f"abfss://{container_name}@{storage_account}.dfs.core.windows.net/{table_name}/"
)

# Define the DLT table to read the data from the source
@dlt.table(name=f"{table_name}_dlt")
def load_taxi_data():
    return spark.read.format("parquet").load(source_path)
