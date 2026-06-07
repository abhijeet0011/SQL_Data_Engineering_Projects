--To run as a script the entire block -->.read "/Users/nimikundu/Abhi/Data_engineering_study/SQL_Data_Engineering_Projects/Lessons /Lessions/1.15:_DDL_DML_Pt2.sql"
/* We gonna learn more about DDL first.
Let's start with CT AS (Create table AS). So basically its for how to use another existing tables' data 
to populate a new table which is needed
Goal is to create another table in jobs_mart database and under Staging schema using CT AS
To do this we need to gather some data from other database */

CREATE OR REPLACE TABLE staging.job_postings_flat AS --OR REPLACE added as we want to rerun this as a script to create a automation
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name,
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;

--Seeing if it worked
SELECT * FROM staging.job_postings_flat
LIMIT 10;

--Seeing if all rows came as we know its 1.6 million rows should be there
SELECT COUNT(*) FROM staging.job_postings_flat;

/* Now time to explore CREATE View
Its a virtual table and no data actually stored
query runs at real time
alaways reflect real data
can be slower(recomputes */
/*As an exampple we gonna combine priority_roles and job_postings_flat tables
from staging schema and create a new view table in main schema */

--WHat we want to combine: 2 tablesas mentioned above for high priority roles
SELECT jpf.*
FROM
    staging.job_postings_flat AS jpf
 JOIN staging.priority_roles as r 
    ON jpf.job_title_short = r.role_name
WHERE r.priority_lvl = 1;

--Now put this SELECT inside CREATE TABLE VIEW
CREATE OR REPLACE VIEW main.priority_jobs_flat_view AS 
SELECT jpf.*
FROM
    staging.job_postings_flat AS jpf
 JOIN staging.priority_roles as r 
    ON jpf.job_title_short = r.role_name
WHERE r.priority_lvl = 1;

--checking if all okay
SELECT count(*) from main.priority_jobs_flat_view;

/* Now time for Temp table explore
Remember when we log out the table is gone
Great for debugging/staging */
--The table doe not stays under any schema so we don need to specify it while creating it
CREATE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT *
FROM main.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

--checking if the creation was correct
SELECT count(*)
FROM senior_jobs_flat_temp;

/* Take away:
If you need the latest data for every query-->Use View
If you need fast rreads and stable esults --> Use CT AS
If you just testing/debugging-> Use Temp table */

/* Lets now explore how to remove/erase entries from tables
DELETE, TRUNCATE, DROP TABLE(should not be used unles really needed)
As a practice let's say in staging.job_postings_flat table,
we want to keep only job postings that is from 2024 or onwards,
so we have to remove all the rows before 2024 */

--DELETE
-- Let's first see the row count to see the initial no. of entries
SELECT count(*) FROM staging.job_postings_flat;
SELECT count(*) FROM main.priority_jobs_flat_view;
SELECT count(*) FROM senior_jobs_flat_temp;

--Now lets delete as per requirement
DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

--Lets now check the output
SELECT count(*) FROM staging.job_postings_flat;
SELECT count(*) FROM main.priority_jobs_flat_view;
SELECT count(*) FROM senior_jobs_flat_temp;

/* As per the output senior_jobs_flat_temp does not get affected because
Because it's an temporary table which does not get automatically updated
unless we update it specifically */

/* TRUNCATE: It will earse all values in the table but keeping the 
strucrure e.g., column names intact */
TRUNCATE TABLE staging.job_postings_flat;
--check if the no. of rows are now 0
SELECT count(*) FROM staging.job_postings_flat;

--Experiment done and let's rebuild the table back
INSERT INTO staging.job_postings_flat
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE job_posted_date >='2024-01-01'; --Just fullfilling our previous requirement to get jobs posted after 2023

--CHeck if the insertion worked
SELECT count(*) FROM staging.job_postings_flat;

/* Take away: for bigger like almost all should be deleted then TRUNCATE
Otherwise DELETE */