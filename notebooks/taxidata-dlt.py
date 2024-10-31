# Import necessary libraries for Delta Live Tables
import dlt
from pyspark.sql.functions import *


############ Need to move this in to common so that we can share across notebooks and DTL ############
class DatabricksSetup:
    def __init__(self, catalog_name="stu_sandbox"):
        self.catalog_name = catalog_name
        self.schemas = [
            {"name": "bronze", "tables": ["taxi_data_cdc", "taxi_data_snapshot"]},
            {"name": "silver", "tables": []},
            {"name": "gold", "tables": []}
        ]
        self.is_setup_done = False
    
    def setup_catalog_and_schemas(self):
        """Creates schemas and volumes if they don't already exist."""
        if not self.is_setup_done:
            for schema in self.schemas:
                schema_name = schema["name"]
                # Create schema if it doesn't exist
                spark.sql(f"CREATE SCHEMA IF NOT EXISTS {self.catalog_name}.{schema_name}")
                print(f"Schema '{schema_name}' created in catalog '{self.catalog_name}'.")
                # Create volume for checkpoints if it doesn't exist
                spark.sql(f"CREATE VOLUME IF NOT EXISTS {self.catalog_name}.{schema_name}.checkpoints")
                print(f"Volume '{self.catalog_name}.{schema_name}.checkpoints' created in catalog '{self.catalog_name}'.")
            self.is_setup_done = True
            print("Catalog and schemas setup completed.")
        else:
            print("Catalog and schemas have already been set up.")
    
    def get_paths(self, table_name):
        """Retrieves the source path, schema location, and checkpoint location for a given table."""
        # Ensure catalog and schemas are set up
        ##self.setup_catalog_and_schemas()
        
        for schema in self.schemas:
            schema_name = schema["name"]
            if table_name in schema["tables"]:
                source_path = f"abfss://taxi-data@stusqlingestdevstore.dfs.core.windows.net/{table_name}/"
                schema_location = f"abfss://taxi-data@stusqlingestdevstore.dfs.core.windows.net/{table_name}/schema/"
                checkpoint_location = f"/Volumes/{self.catalog_name}/{schema_name}/checkpoints/{table_name}"
                return source_path, schema_location, self.catalog_name, checkpoint_location
        
        raise ValueError(f"Unknown table: {table_name}")

# Initialize DatabricksSetup instance
db_setup = DatabricksSetup()
############################################################

# Define widget parameters for DLT pipeline configuration
table_name = spark.conf.get("table_name", "default_table_name")
schema_name = spark.conf.get("schema_name", "default_schema")

# Define paths for source data and Delta table
source_path, schema_location, catalog_name, checkpoint_location = db_setup.get_paths(table_name)
fq_table_name = f"{table_name}_dlt"

# Define the DLT table to read the data from the source
@dlt.table(name=fq_table_name)
def load_taxi_data():
    return spark.read.format("parquet").load(source_path)