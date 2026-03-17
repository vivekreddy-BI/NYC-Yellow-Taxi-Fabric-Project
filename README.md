# 🚖 NYC Taxi Data Analytics - Microsoft Fabric

An end-to-end data engineering and analytics project built using Microsoft Fabric, implementing dynamic data ingestion, metadata-driven pipelines, and reporting on NYC Taxi data.

---

## 📌 Data Source

- NYC Taxi Trip Data (Parquet format - monthly files for 2025)
- Taxi Zone Lookup Table (CSV)

Source: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

---

## 🏗️ Architecture

Raw Files (Parquet + CSV)  
→ Fabric Lakehouse (Files)  
→ Staging (Warehouse - stg schema)  
→ Processed Layer (dbo schema)  
→ Semantic Model  
→ Power BI Dashboard  

---

## ⚙️ Technologies Used

- Microsoft Fabric
- Data Pipelines
- Dataflow Gen2
- Lakehouse & Warehouse
- SQL (Stored Procedures)
- Power BI
- DAX

---

## 🔄 Data Ingestion Strategy

### 1. Initial Setup
- Uploaded Parquet (monthly taxi data) and CSV (zone lookup) into Lakehouse Files
- Created pipeline to load Taxi Zone Lookup into `stg.taxi_zone_lookup`

---

## 🔁 Incremental Data Pipeline (Dynamic)

Implemented a **metadata-driven incremental load pipeline**:
<img width="931" height="152" alt="image" src="https://github.com/user-attachments/assets/22616698-869c-43cc-a35c-cf4787a8d1be" />


### Step 1: Get Last Processed Date
```sql
SELECT TOP 1 latest_processed_pickup
FROM metadata.processing_log
WHERE table_processed = 'Stg_nyctaxi_yellow'
ORDER BY latest_processed_pickup DESC
```
### Step 2: Generate Next File Dynamically

Created variable:
```
v_date = formatDateTime(addToTime(latest_processed_pickup, 1, 'Month'), 'yyyy-MM')
```
Dynamic file name:
```
@concat('yellow_tripdata_',variables('v_date'),'.parquet')
```
### Step 3: Load Data into Staging

Copy activity loads data into: stg.nyctaxi_yellow
Pre Copy Script:

<img width="500" height="80" alt="image" src="https://github.com/user-attachments/assets/094c8c12-60f2-41a7-96dd-31e27fde67d0" />
### Step 4: Data Cleaning (Stored Procedure)

For the Stored Procedure Activity “SP Removing Outlier Dates”.
Create the Stored Procedure stg.data_cleaning_stg in the Data Warehouse using the code below.
```sql
CREATE PROCEDURE stg.data_cleaning_stg
@end_date DATETIME2,
@start_date DATETIME2
AS
DELETE FROM stg.nyctaxi_yellow WHERE tpep_pickup_datetime < @start_date OR tpep_pickup_datetime > @end_date
```
<img width="550" height="200" alt="image" src="https://github.com/user-attachments/assets/9cbb2a7f-cb8b-459c-adc0-9c387d609bab" />

### Step 5: Metadata Tracking
For the Stored Procedure Activity “SP Loading Staging Metadata”.

Code to create the metadata.processing_log table.
```sql
CREATE SCHEMA metadata;

CREATE TABLE metadata.processing_log
(
    pipeline_run_id VARCHAR(255),
    table_processed VARCHAR(255),
    rows_processed INT,
    latest_processed_pickup DATETIME2(6),
    processed_datetime DATETIME2(6) 
);
```
Created the Stored Procedure metadata.insert_staging_metadata in the Data Warehouse using the code below.

```sql
CREATE PROCEDURE metadata.insert_staging_metadata
    @pipeline_run_id VARCHAR(255),
    @table_name VARCHAR(255),
    @processed_date DATETIME2
AS
    insert into metadata.processing_log (pipeline_run_id, table_processed, rows_processed, latest_processed_pickup, processed_datetime)
    SELECT
        @pipeline_run_id AS pipeline_run_id,
        @table_name AS table_processed,
        COUNT(*) AS rows_processed,
        MAX(tpep_pickup_datetime) AS latest_processed_pickup,
        @processed_date AS processed_datetime
    FROM stg.nyctaxi_yellow;
```
<img width="550" height="200" alt="image" src="https://github.com/user-attachments/assets/c9885b28-8c49-42a7-95d0-8b881d558cc1" />

Captures:

Pipeline Run ID

Rows processed

Latest pickup date

Processing timestamp

### 🧱 Data Transformation Pipeline

<img width="500" height="150" alt="image" src="https://github.com/user-attachments/assets/0eaf782a-1985-46e4-8247-233a2f4020b1" />

### Step 1: Dataflow Transformations

<img width="500" height="150" alt="image" src="https://github.com/user-attachments/assets/3643e9db-d69e-403d-96f3-bac0f21cca1a" />

Column renaming

Dropping unnecessary columns

Data type conversions

Column reordering

New column creation

Loaded into:

dbo.nyctaxi_yellow

### Step 2: SP Loading Presentation Metadata

For the Stored Procedure Activity “SP Loading Staging Metadata”.

Create the Stored Procedure metadata.insert_pres_metadata in the Data Warehouse using the code below.
```sql
CREATE PROCEDURE metadata.insert_pres_metadata
    @pipeline_run_id VARCHAR(255),
    @table_name VARCHAR(255),
    @processed_date DATETIME2
AS
    insert into metadata.processing_log (pipeline_run_id, table_processed, rows_processed, latest_processed_pickup, processed_datetime)
    SELECT
        @pipeline_run_id AS pipeline_run_id,
        @table_name AS table_processed,
        COUNT(*) AS rows_processed,
        MAX(tpep_pickup_datetime) AS latest_processed_pickup,
        @processed_date AS processed_datetime
    FROM dbo.nyctaxi_yellow;
```
<img width="500" height="170" alt="image" src="https://github.com/user-attachments/assets/12f3b6b6-fe48-487b-a157-dfd05e7dc3f8" />

## 📊 Semantic Model & Reporting

Built semantic model on top of dbo.nyctaxi_yellow

Created Power BI dashboard with insights:

<img width="705" height="442" alt="Report Screenshort" src="https://github.com/user-attachments/assets/50d29401-dbed-4fad-af67-a497f8e65641" />


Key Insights:

- Total Trips
- Total Revenue
- Trips Over time
- Revenue Over time
- Top Pick Up Zones

## 🚀 Key Highlights

✅ Metadata-driven pipeline design

✅ Dynamic file ingestion (monthly automation)

✅ Incremental data processing

✅ Separation of staging and processed layers

✅ End-to-end Fabric implementation

✅ Real-world ETL pipeline design
