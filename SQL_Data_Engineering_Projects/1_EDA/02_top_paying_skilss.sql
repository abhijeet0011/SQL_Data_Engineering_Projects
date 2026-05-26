/*
Question: WHat are the highest-paying skills for data engineers?
# Calculate the median slaary for each skill required in DE
# Focus on remote positions with specified salaries
# Inlcude skill frequency to identify both salary and emand
# Why?
    # Helps identify which skills command the highest compensation
    while also showig how common those skills are, 
    providing a more complete picture for skill development priorities
    # The median is used instead of avg to reduce the impact of outlier slaries
*/

SELECT * FROM information_schema.tables
where table_catalog = 'data_jobs';

DESCRIBE job_postings_fact;

DESCRIBE skills_dim;

SELECT
    sd.skills as Skill_name, ROUND(MEDIAN(jpf.salary_year_avg), 0) as Median_salary, COUNT(jpf.*) as No_of_job_postings


FROM job_postings_fact as jpf

LEFT JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id

WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_work_from_home = TRUE
    AND jpf.salary_year_avg IS NOT NULL

GROUP BY sd.skills
HAVING COUNT(jpf.*)>100
ORDER BY ROUND(MEDIAN(jpf.salary_year_avg), 0) DESC
LIMIT 25;


/*
────────────┬───────────────┬────────────────────┐
│ Skill_name │ Median_salary │ No_of_job_postings │
│  varchar   │    double     │       int64        │
├────────────┼───────────────┼────────────────────┤
│ terraform  │      184000.0 │                193 │
│ kubernetes │      150500.0 │                147 │
│ airflow    │      150000.0 │                386 │
│ kafka      │      145000.0 │                292 │
│ git        │      140000.0 │                208 │
│ go         │      140000.0 │                113 │
│ pyspark    │      140000.0 │                152 │
│ spark      │      140000.0 │                503 │
│ aws        │      137320.0 │                783 │
│ scala      │      137290.0 │                247 │
│ gcp        │      136000.0 │                196 │
│ mongodb    │      135750.0 │                136 │
│ snowflake  │      135500.0 │                438 │
│ java       │      135000.0 │                303 │
│ github     │      135000.0 │                127 │
│ docker     │      135000.0 │                144 │
│ hadoop     │      135000.0 │                198 │
│ bigquery   │      135000.0 │                123 │
│ python     │      135000.0 │               1133 │
│ r          │      134775.0 │                133 │
│ nosql      │      134415.0 │                193 │
│ databricks │      132750.0 │                266 │
│ mysql      │      130500.0 │                101 │
│ redshift   │      130000.0 │                274 │
│ sql        │      130000.0 │               1128 │
*/
