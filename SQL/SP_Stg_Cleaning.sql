CREATE PROCEDURE stg.data_cleaning_stg
@end_date DATETIME2,
@start_date DATETIME2
AS
DELETE FROM stg.nyctaxi_yellow WHERE tpep_pickup_datetime < @start_date OR tpep_pickup_datetime > @end_date

