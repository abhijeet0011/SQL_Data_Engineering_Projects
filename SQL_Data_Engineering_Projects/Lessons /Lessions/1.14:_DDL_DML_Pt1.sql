/*To run the whole thing as script we have to copy the file relative path and run read command in terminal and the command would be
.read "SQL_Data_Engineering_Projects/Lessons /Lessions/1.14:_DDL_DML_Pt1.sql" */


/*Phase 1: Creating databse and the SQL DDL examples*/

SHOW DATABASES;
USE data_jobs; -- Just putting another database to USE as default in the beginning so that it does not get error for the USE jobs_mart; line later
DROP DATABASE IF  EXISTS jobs_mart; --Very careful with this

CREATE DATABASE IF NOT EXISTS jobs_mart;



--Phase 2: Create Schemas
--FIRST see what schemas we have
SELECT *
FROM information_schema.schemata
WHERE catalog_name = 'jobs_mart';


/*Now time to create Schemas for job_mart database
Since we will use only jobs_mart now so let's tell the editor to use jobs_mart as
default database incase there are other databases.
This will help not to write jobs_mart everytime. For example,
We can replace CREATE SCHEMA jobs_mart.staging with CREATE SCHEMA staging */


USE jobs_mart; -- Telling the editor to use jobs_mart as default onwards
CREATE SCHEMA IF NOT EXISTS staging; --Creating the new schema for jobs_mart


--Droping schema (very careful)
--DROP SCHEMA IF EXISTS staging;


/* Now time to create tables inside Schemas */
--See which tables we have
SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';



--Now create the table, please make sure we create the tbale inside right schema
CREATE TABLE IF NOT EXISTS staging.preferred_roles (
   role_id INTEGER PRIMARY KEY,
   role_name VARCHAR
);


--Practice  DROP table (very careful)
--DROP TABLE IF EXISTS staging.preferred_roles;

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';


/* Now time to insert values in our table */
INSERT INTO staging.preferred_roles (role_id, role_name)
values  (1, 'Data Enginner'),
        (2, 'Senior Data Engineer'),
        (3, 'Software Engineer'),;

--See the results
SELECT *
FROM staging.preferred_roles;

/*ALTER table, add column */
ALTER TABLE staging.preferred_roles
ADD COLUMN new_column BOOLEAN;

/* UPDATE: used to update or correct values in specific columns and not to entire table */
UPDATE staging.preferred_roles
SET new_column = TRUE
WHERE role_id = 1 OR role_id = 2; --Without the where clause It would  update all the rows of the column

UPDATE staging.preferred_roles
SET new_column = FALSE
WHERE role_id = 3;

SELECT *
FROM staging.preferred_roles;

/* Rename column, table name */
--Rename the table
ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

SELECT * FROM staging.priority_roles;

--Rename column
ALTER TABLE staging.priority_roles
RENAME COLUMN new_column TO priority_lvl;

SELECT * FROM staging.priority_roles;

--Update the values: We can change data type, values, drop default etc
ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;  -- boolean is transferrable to Integer, not all data types can be changed to all other type
SELECT * FROM staging.priority_roles;

--Lets update certain value of a cell
UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

SELECT * FROM staging.priority_roles;

