--To run this file: duckdb dw_marts.duckdb -c ".read build_marts.sql"      
-- Step 1: DW- CReate Start Schema tables
.read 01_create_tables_dw.sql

-- Step 2: DW Load data from CSV files
.read 02_load_schema_dw.sql

 -- Step 3: Mart- Create Flat Mart Table
.read 03_create_flat_mart.sql

 -- Step 4: Mart- Create Skills demand mart
.read 04_skills_mart.sql

 -- Step 5: Mart- Create priority mart
.read 05_create_priority_mart.sql

 -- Step 6: Mart- Update priority mart
.read 06_update_priority_mart.sql