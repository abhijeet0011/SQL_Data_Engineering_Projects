/*Time to load the data:
For this we have publicly available google cloud stored csv files for different tables:
https://storage.googleapis.com/sql_de/company_dim.csv
https://storage.googleapis.com/sql_de/skills_dim.csv
https://storage.googleapis.com/sql_de/job_postings_fact.csv
https://storage.googleapis.com/sql_de/skills_job_dim.csv */

--Now insertion of values needs to be sequential as per the drop tables/dependancies we marked in the table creation script

--Populating company_dm table
INSERT INTO company_dim(company_id, name)
SELECT company_id, name
FROM   read_csv("https://storage.googleapis.com/sql_de/company_dim.csv",
        AUTO_DETECT=TRUE);

INSERT INTO skills_dim(skill_id, skills)
SELECT skill_id, skills
FROM   read_csv("https://storage.googleapis.com/sql_de/skills_dim.csv",
        AUTO_DETECT=TRUE);

INSERT INTO job_postings_fact(
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg)
SELECT job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
FROM   read_csv("https://storage.googleapis.com/sql_de/job_postings_fact.csv",
        AUTO_DETECT=TRUE);

INSERT INTO skills_job_dim(skill_id, job_id)
SELECT skill_id, job_id
FROM   read_csv("https://storage.googleapis.com/sql_de/skills_job_dim.csv",
        AUTO_DETECT=TRUE);


SELECT * from company_dim Limit 2;
SELECT * from skills_dim Limit 2;
SELECT * from job_postings_fact Limit 2;
SELECT * from skills_job_dim Limit 2;

--Data validation
/*After commiting the changes with build_marts script time to 
Validate data. For this lets not create and load data again and again
and just validate inside here with duckdb commands
For that we have to run several queries and lets
point duckdb to our database to do that 
The command is duckdb database_name
*/
SELECT 'Company Dim' AS table_name, COUNT(*) AS record_count FROM company_dim
UNION ALL 
SELECT 'Skill Dim', COUNT(*) FROM skills_dim
UNION ALL 
SELECT 'Job posting fact', COUNT(*) FROM job_postings_fact
UNION ALL 
SELECT 'Skill Job Dim', COUNT(*) FROM skills_job_dim;