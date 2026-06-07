-- SUbqueries
-- Scenario 1: Subquery in SELECT statement
-- SHow each job's median salary next to the overall market median
SELECT
job_title_short, MEDIAN(salary_year_avg),
(
        SELECT MEDIAN(salary_year_avg)
        FROM   job_postings_fact
) AS market_median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;


-- Scenario 2: Subquery in FROM
-- STage only jobs that are remote before aggregating to determine the remote median salary job
SELECT
job_title_short, 
MEDIAN(salary_year_avg),
(
    SELECT MEDIAN(salary_year_avg)
        FROM   job_postings_fact
        WHERE job_work_from_home = TRUE
) AS market_median_salary

FROM (
    SELECT job_title_short,
    salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs
WHERE salary_year_avg IS NOT NULL
GROUP by 1;


-- Scenario 3: Subquery in HAVING
-- Same but Keep only jobs whose median salary > overall median
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) as median_salary,
    (
    SELECT
        MEDIAN(salary_year_avg)
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
    AND job_work_from_home = TRUE
    ) as overall_median_salary

    FROM (
        SELECT
        job_title_short,
        salary_year_avg
        FROM job_postings_fact
        WHERE salary_year_avg IS NOT NULL
        AND job_work_from_home = TRUE
    ) 
GROUP BY 1
HAVING median_salary > overall_median_salary;


/* Let's start CTE (Common Table Expression)
--Compare how much more (or less) remote roles pay compared to onsite riles for each job title
-- Use a CTE to calculate the emdian salary by title and work arrangment, then compare those medians */

WITH temp_table AS (
    SELECT job_title_short,
            MEDIAN(CASE WHEN job_work_from_home =TRUE THEN salary_year_avg END) AS median_of_salary_overall_from_home,
            MEDIAN(CASE WHEN job_work_from_home =FALSE THEN salary_year_avg END) AS median_of_salary_overall_onsite
            FROM job_postings_fact
            WHERE 
                salary_year_avg IS NOT NULL
            AND job_country = 'United States'
            GROUP by 1
            )
SELECT 
    job_title_short, 
    median_of_salary_overall_from_home,
    median_of_salary_overall_onsite,
   median_of_salary_overall_from_home - median_of_salary_overall_onsite
FROM    temp_table
ORDER BY 1;



--Another interesting way:
WITH title_median AS (
    SELECT job_title_short,
    job_work_from_home,
    MEDIAN(salary_year_avg) :: INT AS median_salary 
    FROM job_postings_fact
    WHERE job_country = 'United States'
    GROUP BY 1,2
)
SELECT
    r.job_title_short,
    r.median_salary,
    o.median_salary,
    r.median_salary - o.median_salary
    FROM title_median AS r 
    INNER JOIN title_median AS o 
    ON r.job_title_short = o.job_title_short

    WHERE r.job_work_from_home = TRUE
    AND o.job_work_from_home = FALSE 
    ORDER BY 1;


-/* Source table -- > Target table data transfer
1. Using where Exists: Return value of the source table which matches between a source and target table
2. Using where NOT Exists: Return value of the source table which doesn't match between a source and target table */
--Let's create a source table and a target table for example
--SOurce table:
SELECT *
FROM range(3) AS src(key); --range function creates entries of the mentioned number, in this case 0,1,2 and src function rename the column name

--Target table
SELECT *
FROM  range(2) AS tgt(key);

--WHere exist:
SELECT *
FROM range(3) AS src(key)
WHERE EXISTS (
    SELECT 1
    FROM range(2) AS tgt(key)
    WHERE tgt.key = src.key
);

--Where NOT Exists

SELECT * 
FROM range(3) AS src(key)
WHERE NOT EXISTS (
    SELECT 1
    FROM range(2) AS tgt(key)
    WHERE tgt.key = src.key
);

--NOw with a real life example with our database
-- Identify job postings that have no associated skills before loading them into a data mart
SELECT job_title_short,job_id
FROM job_postings_fact as tgt
WHERE NOT EXISTS (
    SELECT 1
    FROM skills_job_dim as src
    WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;