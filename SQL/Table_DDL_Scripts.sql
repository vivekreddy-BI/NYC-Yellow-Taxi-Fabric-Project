CREATE SCHEMA metadata;

CREATE TABLE metadata.processing_log
(
    pipeline_run_id VARCHAR(255),
    table_processed VARCHAR(255),
    rows_processed INT,
    latest_processed_pickup DATETIME2(6),
    processed_datetime DATETIME2(6) 
);


CREATE TABLE dbo.nyctaxi_yellow
(
    vendor VARCHAR(50),
    tpep_pickup_datetime DATE,
    tpep_dropoff_datetime DATE,
    pu_borough VARCHAR(100),
    pu_zone VARCHAR(100),
    do_borough VARCHAR(100),
    do_zone VARCHAR(100),
    payment_method VARCHAR(50),
    passenger_count INT,
    trip_distance FLOAT,
    total_amount FLOAT
);