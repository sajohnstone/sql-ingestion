CREATE TABLE cdc.dbo_TaxiData_CT (
    __$start_lsn VARBINARY(10) NOT NULL,
    __$seqval VARBINARY(10) NOT NULL,
    __$operation INT NOT NULL,
    __$update_mask VARBINARY(10) NULL,
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
    congestion_surcharge FLOAT,
    ChangeDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_TaxiData_Insert
ON dbo.TaxiData
AFTER INSERT
AS
BEGIN
    INSERT INTO cdc.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        1,                               -- Operation type: 1 = INSERT
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM inserted;
END;

CREATE TRIGGER trg_TaxiData_Update
ON dbo.TaxiData
AFTER UPDATE
AS
BEGIN
    INSERT INTO cdc.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, __$update_mask, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        2,                               -- Operation type: 2 = UPDATE
        0x01,                            -- Example update mask indicating which columns were updated
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM inserted;
END;

CREATE TRIGGER trg_TaxiData_Delete
ON dbo.TaxiData
AFTER DELETE
AS
BEGIN
    INSERT INTO cdc.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        3,                               -- Operation type: 3 = DELETE
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM deleted;
END;

CREATE FUNCTION cdc.fn_get_all_changes_taxi_data()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM cdc.dbo_TaxiData_CT
);

