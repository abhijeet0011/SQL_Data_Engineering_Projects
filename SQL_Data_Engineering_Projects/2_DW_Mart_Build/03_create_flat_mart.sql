/*Now the idea is not to create a separate database for Mart tables but separate DW and Mart tables in different schemas. So DW will be in the main schema where Marts will be in a different schema.
First create new feature branch git switch -c feature/flat-mart
Always remeber before creating schema or table we have to 
think the script will be repeated as its gonna be an automated pipeline
So DROP and REPLACE keywords are used whenever applicable*/


--Dropping schema if exists before creating it
DROP SCHEMA IF EXISTS flat_mart CASCADE; --cascade was important otherse there would be error rerunniing the script as the flat mart table depend on this schema
--Creating different schema for Mart
CREATE SCHEMA flat_mart;

CREATE OR REPLACE TABLE  flat_mart.job_postings AS 
SELECT 
    jpf.job_id,
    jpf.company_id,
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
    -- from comapny_di
    cd.company_id, 
    cd.name AS company_name,
    -- we need to take skil and type within a single column, so need array struct
    ARRAY_AGG(
        STRUCT_PACK(
            type := sd.type,
            name := sd.skills
        )
    ) AS skills_and_type

FROM  job_postings_fact as jpf
LEFT JOIN company_dim AS cd 
    ON jpf.company_id = cd.company_id
LEFT JOIN skills_job_dim AS sjd 
    ON jpf.job_id = sjd.job_id 
LEFT JOIN skills_dim AS sd 
    ON sjd.skill_id = sd.skill_id 
GROUP BY jpf.job_id,
    jpf.company_id,
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
    cd.company_id, 
    cd.name;


-- Data validation
SELECT 'Flat Mart Job Postings' AS table_name, COUNT(*) AS record_count FROM flat_mart.job_postings;