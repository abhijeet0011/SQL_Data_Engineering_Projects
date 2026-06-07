/* Question: Identify the top 10 in-demand skills for DE
Focus on remote job postings */

SELECT * from information_schema.tables
WHERE table_catalog = 'data_jobs';

DESCRIBE skills_dim;
DESCRIBE job_postings_fact;




SELECT
    sd.skills as skill_name, COUNT(jpf.*) as no_of_job_post
FROM job_postings_fact as jpf

LEFT JOIN skills_job_dim as sjd
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = TRUE   
GROUP BY sd.skills
ORDER BY
    COUNT(jpf.*) DESC  
LIMIT 10;


/*
Output
┌────────────┬────────────────┐
│ skill_name │ no_of_job_post │
│  varchar   │     int64      │
├────────────┼────────────────┤
│ sql        │          29221 │
│ python     │          28776 │
│ aws        │          17823 │
│ azure      │          14143 │
│ spark      │          12799 │
│ airflow    │           9996 │
│ snowflake  │           8639 │
│ databricks │           8183 │
│ java       │           7267 │
│ gcp        │           6446 │
└────────────┴────────────────┘
*/

