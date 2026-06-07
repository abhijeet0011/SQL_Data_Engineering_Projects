--Checking data tyoes from table
SELECT 
    table_name,
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    table_name = 'job_postings_fact';

--CAST i.e., chnaging data types
SELECT
    job_id,
    CAST(job_work_from_home AS INT), --converted from Bool to Int
    CAST(job_posted_date as DATE), --from timestamp to date only
    CAST(salary_year_avg AS DECIMAL(10,0)) --from double to decimal
FROM 
    job_postings_fact
LIMIT 10;

--Now combine job and company ID together (Excercize)
SELECT
    CAST(job_id AS VARCHAR)|| CAST(company_id AS VARCHAR),
    CAST(job_work_from_home AS INT), --converted from Bool to Int
    CAST(job_posted_date as DATE), --from timestamp to date only
    CAST(salary_year_avg AS DECIMAL(10,0)) --from double to decimal
FROM 
    job_postings_fact
LIMIT 10;

--We can also fix the data type of the output
SELECT (3+5.5)::INT; -- Keeping the output as INT and the result is 9
SELECT (3+5.5)::FLOAT; -- Keeping the output as INT and the result is 8.5
