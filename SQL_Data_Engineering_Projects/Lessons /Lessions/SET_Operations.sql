/* UNION/UNION ALL, EXCEPT/EXCEPT all, INTERSECT/INTERSECT all */

SELECT [1, 1, 1, 2]; --Just selecting list values
/*
─────────────────────────────┐
│ main.list_value(1, 1, 1, 2) │
│           int32[]           │
├─────────────────────────────┤
│ [1, 1, 1, 2]                │
└─────────────────────────────┘*/
--To make it as rows:
SELECT UNNEST([1, 1, 1, 2]);
/* unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
│                                   1 │
│                                   1 │
│                                   2 │
└─────────────────────────────────────┘*/
--UNION
SELECT UNNEST([1, 1, 1, 2])
UNION 
    SELECT UNNEST([1, 1, 3]);
/* unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   2 │
│                                   1 │
│                                   3 │
└─────────────────────────────────────┘*/

SELECT UNNEST([1, 1, 1, 2])
UNION ALL
    SELECT UNNEST([1, 1, 3]);
    /* unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
│                                   1 │
│                                   1 │
│                                   2 │
│                                   1 │
│                                   1 │
│                                   3 │*/

SELECT UNNEST([1, 1, 1, 2])
INTERSECT
    SELECT UNNEST([1, 1, 3]);
/* unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │*/

SELECT UNNEST([1, 1, 1, 2])
INTERSECT ALL
    SELECT UNNEST([1, 1, 3]);
    /*─────────────────────────────────────┐
│ unnest(main.list_value(1, 1, 1, 2)) │
│                int32                │
├─────────────────────────────────────┤
│                                   1 │
│                                   1 │
└─────────────────────────────────────┘*/

/* Real life scenario */
--Which job postings are unique in between 2023 and 2024
CREATE TEMP TABLE tempo AS
    SELECT * EXCLUDE(job_id, job_posted_date) --This Exclude is only available in Duckdb and few other tools, otherwise had to name all columns
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2023
    UNION
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2024;

SELECT * from tempo;

--What job positings appears commonly in both 2023 and 2024
CREATE TEMP TABLE tempo2 AS
    SELECT * EXCLUDE(job_id, job_posted_date) --This Exclude is only available in Duckdb and few other tools, otherwise had to name all columns
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2023
    INTERSECT
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2024;

SELECT * from tempo2;

--What job positings appears commonly in both 2023 and 2024, preserving duplicates
CREATE TEMP TABLE tempo5 AS
    SELECT * EXCLUDE(job_id, job_posted_date) --This Exclude is only available in Duckdb and few other tools, otherwise had to name all columns
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2023
    INTERSECT ALL
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2024;

SELECT * from tempo5;

--Which job postings appeared in 2023 but not in 2024
CREATE TEMP TABLE tempo3 AS
    SELECT * EXCLUDE(job_id, job_posted_date) --This Exclude is only available in Duckdb and few other tools, otherwise had to name all columns
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2023
    EXCEPT
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2024;

SELECT * from tempo3;

--Which job posting remain after subtracting matching 2024 postings, one-for-one?
CREATE TEMP TABLE tempo4 AS
    SELECT * EXCLUDE(job_id, job_posted_date) --This Exclude is only available in Duckdb and few other tools, otherwise had to name all columns
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2023
    EXCEPT ALL
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE EXTRACT(YEAR FROM job_posted_date) =2024;

SELECT * from tempo4;