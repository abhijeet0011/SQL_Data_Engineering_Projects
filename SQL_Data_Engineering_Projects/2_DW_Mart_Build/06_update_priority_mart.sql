--Update priority mart

SELECT '===Updating Roles for Priority Mart==' AS info;

-- Update Data Engineer to Priority 1
UPDATE priority_mart.priority_roles
SET priority_lvl = 1
WHERE role_name = 'Data Engineer';

-- Add Data Scientist as Level 3
INSERT INTO priority_mart.priority_roles(role_id, role_name, priority_lvl)
VALUES (4, 'Data Scientist', 3);

--Data validation
SELECT * FROM priority_mart.priority_roles;

SELECT '===Creating Temp source table for Priority Mart==' AS info;

--Create Temp source table
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM   job_postings_fact as jpf --we did not write data_jobs.main.job_postings_fact as by default schema is the main schema if not specified
LEFT JOIN company_dim as cd --LEFT jpin becuase we want to keep all from jpf while matching with company
ON jpf.company_id = cd.company_id
INNER JOIN priority_mart.priority_roles r --Inner join because we only want to keep only the roles those are in the priority_roles table
ON  jpf.job_title_short = r.role_name;


SELECT '===Batch updating priority_jobs_snapshot==' AS info;
--Incremental update as Merge combine update, insert, delete
MERGE INTO priority_mart.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN --update part when matched and with new entry, in our cae we only carewhen for a matched row the priority level changes
    UPDATE SET  priority_lvl = src.priority_lvl,
                updated_at = src.updated_at

WHEN NOT MATCHED THEN
    INSERT  (job_id,   --In tis case INSERT instead of INSERT INTO, because in the first line of MERGE statement target table is defined already
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES (
    src.job_id,
    src.job_title_short,
    src.name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)

WHEN NOT MATCHED BY SOURCE THEN DELETE;

--Data validation
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl),
MIN(updated_at)
FROM priority_mart.priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;