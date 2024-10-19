import pyodbc
import pandas as pd
import os
import sys
import time
from dotenv import load_dotenv
from tqdm import tqdm  # Import tqdm for the progress bar

# Path to your .env file
env_path = "dev.env"
data_file_path = './data/data.csv'

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

# Create the table if it doesn't exist
create_table_query = """
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TaxiData' AND xtype='U')
CREATE TABLE TaxiData (
    VendorID INT,
    tpep_pickup_datetime DATETIME,
    tpep_dropoff_datetime DATETIME,
    passenger_count INT,
    trip_distance FLOAT,
    RatecodeID INT,
    store_and_fwd_flag CHAR(1),
    PULocationID INT,
    DOLocationID INT,
    payment_type INT,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT
);
"""
cursor.execute(create_table_query)
conn.commit()

# Load data from CSV
data = pd.read_csv(data_file_path)

# Insert query
insert_query = """
INSERT INTO TaxiData (VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, 
                      RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID, payment_type, fare_amount, 
                      extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
"""

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
total_batches = (len(data_tuples) + batch_size - 1) // batch_size  # Calculate total number of batches
with tqdm(total=total_batches, desc="Inserting batches", unit="batch") as pbar:
    for i in range(0, len(data_tuples), batch_size):
        batch = data_tuples[i:i + batch_size]
        insert_batch(cursor, batch)
        pbar.update(1)  # Update the progress bar by 1 after each batch is inserted

# Close the cursor and connection
cursor.close()
conn.close()

print("Data inserted successfully.")