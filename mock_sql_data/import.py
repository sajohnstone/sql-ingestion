import pyodbc
import pandas as pd
import os
import sys
import time
from dotenv import load_dotenv
from tqdm import tqdm  # Import tqdm for the progress bar
import argparse  # Import argparse for command-line arguments

# Argument parser setup
parser = argparse.ArgumentParser(description='Import data into SQL Server.')
parser.add_argument('--max_records', type=int, help='Maximum number of records to import', default=None)

args = parser.parse_args()

# Path to your .env file
env_path = "./dev.env"
data_file_path = './mock_sql_data/data/data.csv'
sql_commands_path = './mock_sql_data/sql/'

# Sense checks
if not os.path.exists(env_path):
    print(f"Error: .env file not found at {env_path}")
    sys.exit(1)
if not os.path.exists(data_file_path):
    print(f"Error: data file not found at {data_file_path}")
    sys.exit(1)

# Load the .env file
load_dotenv(env_path)

# Access the environment variables
server = os.getenv("SERVER")
database = os.getenv("DATABASE")
username = os.getenv("USERNAME")
password = os.getenv("PASSWORD")
driver = '{ODBC Driver 17 for SQL Server}'

print(f"Connecting to server: {server}, database: {database}")

# Establish the connection
connection_string = f'Driver={driver};Server={server};Database={database};UID={username};PWD={password};'

# Retry mechanism parameters
max_retries = 5
retry_delay = 5  # seconds

def connect_to_db():
    """Attempts to connect to the database, with retries on failure."""
    for attempt in range(max_retries):
        try:
            conn = pyodbc.connect(connection_string)
            return conn
        except pyodbc.Error as e:
            print(f"Connection attempt {attempt + 1} failed. Retrying in {retry_delay} seconds...")
            time.sleep(retry_delay)
    print("Failed to connect to the database after multiple attempts.")
    sys.exit(1)

# Establish connection with retries
conn = connect_to_db()
cursor = conn.cursor()

def read_sql_file(file_path):
    with open(file_path, 'r') as file:
        sql_script = file.read()
    
    # Split the SQL script by 'GO' keyword (case-insensitive and ensuring it works for multiple spaces/newlines)
    sql_commands = [cmd.strip() for cmd in sql_script.split('GO') if cmd.strip()]
    return sql_commands

# Execute each SQL command separately
def execute_sql_commands(commands, cursor, conn):
    for command in commands:
        try:
            print("**** Executing ****")
            print(f"{command.splitlines()[0]}")
            cursor.execute(command)
            conn.commit()  # Commit after each command
            print("**** Command complete ****")
        except Exception as e:
            print("**** Command failed ****")
            print("**** ERROR ****")
            print(f"Error: {str(e)}")
            print("**** END OF ERROR ****")
            conn.rollback()  # Rollback if there's an error
            sys.exit(1)

# Create table
print("Creating table...")
sql_commands = read_sql_file(f"{sql_commands_path}/create_taxi_table.sql")
execute_sql_commands(sql_commands, cursor, conn)

# Load data from CSV
print("Loading data from CSV...")
data = pd.read_csv(data_file_path)

# Apply max_records if specified
if args.max_records is not None:
    data = data.head(args.max_records)

# Insert query
insert_query = read_sql_file(f"{sql_commands_path}/insert_taxi_record.sql")[0] 

# Convert DataFrame to list of tuples
data_tuples = list(data.itertuples(index=False, name=None))

# Batch processing parameters
batch_size = 1000

def insert_batch(cursor, batch):
    """Inserts a batch of data and handles retrying."""
    for attempt in range(max_retries):
        try:
            cursor.executemany(insert_query, batch)
            conn.commit()
            return
        except pyodbc.Error as e:
            print(f"Insert attempt {attempt + 1} failed. Retrying in {retry_delay} seconds...")
            time.sleep(retry_delay)
    print(f"Failed to insert batch after {max_retries} attempts.")
    sys.exit(1)

# Process data in batches and display progress
print("Inserting data in batches...")
total_batches = (len(data_tuples) + batch_size - 1) // batch_size  # Calculate total number of batches
with tqdm(total=total_batches, desc="Inserting batches", unit="batch") as pbar:
    for i in range(0, len(data_tuples), batch_size):
        batch = data_tuples[i:i + batch_size]
        insert_batch(cursor, batch)
        pbar.update(1)  # Update the progress bar by 1 after each batch is inserted


# Simulate CDC
print("Setting up CDC simulation...")
sql_commands = read_sql_file(f"{sql_commands_path}/simulate_taxi_cdc.sql")
execute_sql_commands(sql_commands, cursor, conn)

# Close the cursor and connection
cursor.close()
conn.close()

print("Data inserted successfully.")