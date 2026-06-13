/*this will include batch load
first create the feature branch for this in git-->git switch -c feature/priority-mart*/
-- STep 5: Mart - Create priority roles mart

DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

--First create priority_roles table
CREATE TABLE priority_mart.priority_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

INSERT INTO priority_mart.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

--Data validation:
SELECT * FROM priority_mart.priority_roles;

--Now create priority_jobs_snapshot table
CREATE OR REPLACE TABLE priority_mart.priority_jobs_snapshot (
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot (
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
FROM   job_postings_fact as jpf 
LEFT JOIN company_dim as cd --LEFT jpin becuase we want to keep all from jpf while matching with company
ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles r --Inner join because we only want to keep only the roles those are in the priority_roles table
ON  jpf.job_title_short = r.role_name;

--Data validation
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl),
MIN(updated_at)
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;