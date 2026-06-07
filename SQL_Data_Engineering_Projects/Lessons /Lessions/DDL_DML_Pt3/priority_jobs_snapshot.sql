/* After the initial creation and v1 load, now its time to update the table (v2) with the changes from source tables
1. Any unmatched incoming rows-->We have to INSERT them in the destination table
2. Any unmatched existing row--> We have to DELETE those
3. Any MATCHED rows in between incoming and existing data--> We have to UPDTAE the existing values with teh new incoming ones
Since our source tables are multiple, would be great iea to create a temporary table sombining those source tables */

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
FROM   data_jobs.job_postings_fact as jpf --we did not write data_jobs.main.job_postings_fact as by default schema is the main schema if not specified
LEFT JOIN data_jobs.company_dim as cd --LEFT jpin becuase we want to keep all from jpf while matching with company
ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles r --Inner join because we only want to keep only the roles those are in the priority_roles table
ON  jpf.job_title_short = r.role_name;

/*UPDATE for the matcheed rows where new values are 
available for the existing match rows, 
in this case if priority level changes for a existing role */
-- UPDATE main.priority_jobs_snapshot AS tgt 
-- SET 
--     priority_lvl = src.priority_lvl,
--     updated_at = src.updated_at
-- FROM src_priority_jobs AS src 
-- WHERE tgt.job_id = src.job_id
--     AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl; -- This DIstinct From is actually the one checks which rows got changed


-- --Insert for brand new values
-- INSERT INTO main.priority_jobs_snapshot (
--     job_id,
--     job_title_short,
--     company_name,
--     job_posted_date,
--     salary_year_avg,
--     priority_lvl,
--     updated_at
-- )
-- SELECT
--     src.job_id,
--     src.job_title_short,
--     src.name,
--     src.job_posted_date,
--     src.salary_year_avg,
--     src.priority_lvl,
--     CURRENT_TIMESTAMP AS updated_at
-- FROM src_priority_jobs AS src
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM main.priority_jobs_snapshot AS tgt
--     WHERE tgt.job_id = src.job_id
-- );


-- /* DELETE the entries from target table which
-- are not anymore available in the updated src table
-- in this case its the job_title_short */
-- DELETE FROM main.priority_jobs_snapshot as tgt 
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM src_priority_jobs AS src 
--     WHERE src.job_id = tgt.job_id
-- );

/*We can do all these 3 steps using MEREGE stateents*/
MERGE INTO priority_jobs_snapshot AS tgt
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

--See the output
SELECT job_title_short,
COUNT(*) as job_count,
MIN(priority_lvl),
MIN(updated_at)
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;