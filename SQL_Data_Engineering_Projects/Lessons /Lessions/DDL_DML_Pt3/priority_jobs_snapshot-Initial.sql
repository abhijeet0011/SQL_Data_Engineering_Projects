/* NOw time to create and make an initial load (V1)  to the desired /destination table 
priority_jobs_snapshot 
and make the v1 load */
CREATE OR REPLACE TABLE main.priority_jobs_snapshot (
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

INSERT INTO main.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP --to get the present timestamp
FROM   data_jobs.job_postings_fact as jpf --we did not write data_jobs.main.job_postings_fact as by default schema is the main schema if not specified
LEFT JOIN data_jobs.company_dim as cd --LEFT jpin becuase we want to keep all from jpf while matching with company
ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles r --Inner join because we only want to keep only the roles those are in the priority_roles table
ON  jpf.job_title_short = r.role_name;

--See the output
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl),
MIN(updated_at)
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;