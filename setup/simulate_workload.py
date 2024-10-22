import pyodbc
import random
import time
import os
import sys
from dotenv import load_dotenv

# Path to your .env file
env_path = "./dev.env"

if not os.path.exists(env_path):
    print(f"Error: .env file not found at {env_path}")
    sys.exit(1)
load_dotenv(env_path)

# Database connection parameters
server = os.getenv("SERVER")
database = os.getenv("DATABASE")
username = os.getenv("USERNAME")
password = os.getenv("PASSWORD")
driver = '{ODBC Driver 17 for SQL Server}'
connection_string = f'Driver={driver};Server={server};Database={database};UID={username};PWD={password};'

# Connect to the database
def connect_to_db():
    """Establish a connection to the database."""
    try:
        conn = pyodbc.connect(connection_string)
        return conn
    except pyodbc.Error as e:
        print(f"Database connection failed: {e}")
        sys.exit(1)

# Retrieve IDs from TaxiData table
def get_ids(cursor):
    """Get all IDs from the TaxiData table."""
    cursor.execute("SELECT VendorID FROM TaxiData")
    return [row[0] for row in cursor.fetchall()]

# Load SQL from file
def load_sql_from_file(file_path):
    """Load SQL query from a given file."""
    with open(file_path, 'r') as file:
        return file.read()

# Insert new record into TaxiData
def insert_record(cursor):
    """Insert a new record into the TaxiData table."""
    print("starting update...")
    new_record = (
        random.randint(1, 10),  # VendorID
        '2024-10-20 10:00:00',  # tpep_pickup_datetime
        '2024-10-20 10:30:00',  # tpep_dropoff_datetime
        random.randint(1, 5),    # passenger_count
        round(random.uniform(1.0, 10.0), 2),  # trip_distance
        random.randint(1, 5),    # RatecodeID
        random.choice(['Y', 'N']),  # store_and_fwd_flag
        random.randint(1, 100),   # PULocationID
        random.randint(1, 100),   # DOLocationID
        random.randint(1, 5),     # payment_type
        round(random.uniform(1.0, 100.0), 2),  # fare_amount
        round(random.uniform(0.0, 10.0), 2),   # extra
        round(random.uniform(0.0, 5.0), 2),    # mta_tax
        round(random.uniform(0.0, 20.0), 2),   # tip_amount
        round(random.uniform(0.0, 10.0), 2),    # tolls_amount
        round(random.uniform(0.0, 5.0), 2),     # improvement_surcharge
        round(random.uniform(1.0, 150.0), 2),   # total_amount
        round(random.uniform(0.0, 5.0), 2)      # congestion_surcharge
    )
    
    insert_query = load_sql_from_file('./sql/insert_taxi_record.sql')
    cursor.execute(insert_query, new_record)
    print(f"Inserted record: {new_record}")

# Update an existing record in TaxiData
def update_record(cursor, id_to_update):
    """Update a record in the TaxiData table."""
    print("starting update...")
    update_query = load_sql_from_file('./sql/update_taxi_record.sql')
    
    new_passenger_count = random.randint(1, 5)
    new_trip_distance = round(random.uniform(1.0, 10.0), 2)
    new_fare_amount = round(random.uniform(1.0, 100.0), 2)
    
    cursor.execute(update_query, (new_passenger_count, new_trip_distance, new_fare_amount, id_to_update))
    print(f"Updated record with VendorID {id_to_update}: passenger_count={new_passenger_count}, trip_distance={new_trip_distance}, fare_amount={new_fare_amount}")

# Delete a record from TaxiData
def delete_record(cursor, id_to_delete):
    """Delete a record from the TaxiData table."""
    print("starting delete...")
    delete_query = load_sql_from_file('./sql/delete_taxi_record.sql')
    cursor.execute(delete_query, id_to_delete)
    print(f"Deleted record with VendorID {id_to_delete}")

# Main function to simulate workload
def simulate_workload():
    conn = connect_to_db()
    cursor = conn.cursor()

    print("Fetching ids to be able to simulate delete / updates...")
    ids = get_ids(cursor)
    if not ids:
        print("No records found in TaxiData. Please insert records before running the simulation.")
        conn.close()
        return

    actions = ['insert', 'update', 'delete']
    max_time_between_actions = 10  # Max wait time in seconds

    print("Starting simulation...")
    try:
        while True:
            action = random.choice(actions)

            if action == 'insert':
                insert_record(cursor)
            elif action == 'update' and ids:
                id_to_update = random.choice(ids)
                update_record(cursor, id_to_update)
            elif action == 'delete' and ids:
                id_to_delete = random.choice(ids)
                delete_record(cursor, id_to_delete)
                ids.remove(id_to_delete)  # Remove ID from list to avoid deleting it again

            # Wait for a random amount of time
            wait_time = random.uniform(1, max_time_between_actions)
            print(f"Waiting for {wait_time:.2f} seconds before next action...")
            time.sleep(wait_time)

            # Optionally, re-fetch IDs to get the latest state of the table
            ids = get_ids(cursor)

    except KeyboardInterrupt:
        print("Workload simulation stopped.")

    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    simulate_workload()