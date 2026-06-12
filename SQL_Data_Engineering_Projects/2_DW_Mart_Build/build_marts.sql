--To run this file: duckdb dw_marts.duckdb -c ".read build_marts.sql"      
-- Step 1: DW- CReate Start Schema tables
.read 01_create_tables_dw.sql

-- Step 2: DW Load data from CSV files
.read 02_load_schema_dw.sql

 -- Step 3: Mart- Create Flat Mart Table
.read 03_create_flat_mart.sql