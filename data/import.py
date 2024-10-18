import pyodbc
import pandas as pd

# Define your connection string
server = '<your-server-name>.database.windows.net'
database = '<your-database-name>'
username = 'db_admin'
password = '<your-password>'
driver = '{ODBC Driver 17 for SQL Server}'

# Establish the connection
connection_string = f'Driver={driver};Server={server};Database={database};UID={username};PWD={password};'
conn = pyodbc.connect(connection_string)

# Create a cursor from the connection
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
data_file_path = 'data.csv'  # Update this to the path of your data.csv file
data = pd.read_csv(data_file_path)

# Insert data into the table
insert_query = """
INSERT INTO TaxiData (VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count, trip_distance, 
                      RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID, payment_type, fare_amount, 
                      extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
"""

# Convert DataFrame to list of tuples
data_tuples = list(data.itertuples(index=False, name=None))

# Execute the insert for each row
cursor.executemany(insert_query, data_tuples)
conn.commit()

# Close the cursor and connection
cursor.close()
conn.close()

print("Data inserted successfully.")