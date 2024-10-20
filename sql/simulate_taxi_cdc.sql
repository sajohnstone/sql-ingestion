-- Create the change tracking table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'dbo_TaxiData_CT' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.dbo_TaxiData_CT (
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
END;
GO
-- Drop existing triggers if they exist and recreate them

-- Trigger for INSERT operation
IF OBJECT_ID('dbo.trg_TaxiData_Insert', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_TaxiData_Insert;
GO
CREATE TRIGGER trg_TaxiData_Insert
ON dbo.TaxiData
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        2,                               -- Operation type: 2 = INSERT
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM inserted;
END;
GO
-- Trigger for UPDATE operation
IF OBJECT_ID('dbo.trg_TaxiData_Update', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_TaxiData_Update;
GO
CREATE TRIGGER trg_TaxiData_Update
ON dbo.TaxiData
AFTER UPDATE
AS
BEGIN
    -- Insert old values (previous state) into the change tracking table
    INSERT INTO dbo.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, __$update_mask, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        3,                               -- Operation type: 3 = UPDATE OLD
        0x01,                            -- Update mask indicating which columns were updated
        t.VendorID, t.tpep_pickup_datetime, t.tpep_dropoff_datetime,
        t.passenger_count, t.trip_distance, t.RatecodeID, t.store_and_fwd_flag, t.PULocationID, t.DOLocationID,
        t.payment_type, t.fare_amount, t.extra, t.mta_tax, t.tip_amount, t.tolls_amount, t.improvement_surcharge,
        t.total_amount, t.congestion_surcharge
    FROM deleted t
    INNER JOIN inserted i ON t.VendorID = i.VendorID;

    -- Insert new values (new state) into the change tracking table
    INSERT INTO dbo.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, __$update_mask, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        4,                               -- Operation type: 4 = UPDATE NEW
        0x01,                            -- Update mask indicating which columns were updated
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM inserted;
END;
GO
-- Trigger for DELETE operation
IF OBJECT_ID('dbo.trg_TaxiData_Delete', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_TaxiData_Delete;
GO
CREATE TRIGGER trg_TaxiData_Delete
ON dbo.TaxiData
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.dbo_TaxiData_CT (__$start_lsn, __$seqval, __$operation, VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge)
    SELECT 
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$start_lsn
        CAST(NEWID() AS VARBINARY(10)),  -- Simulating __$seqval
        1,                               -- Operation type: 1 = DELETE
        VendorID, tpep_pickup_datetime, tpep_dropoff_datetime,
        passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID,
        payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge,
        total_amount, congestion_surcharge
    FROM deleted;
END;
GO
-- Function to get all changes
IF OBJECT_ID('dbo.fn_get_all_changes_taxi_data') IS NOT NULL
    DROP FUNCTION dbo.fn_get_all_changes_taxi_data;
GO
CREATE FUNCTION dbo.fn_get_all_changes_taxi_data()
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM dbo.dbo_TaxiData_CT
);