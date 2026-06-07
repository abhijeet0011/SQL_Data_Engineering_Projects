/* CASE Expression use cases */

-- Bucketing data
SELECT job_title_short, 
    median(salary_year_avg),
    CASE WHEN median(salary_year_avg) > 130000 THEN 'High Salary'
        WHEN median(salary_year_avg) > 100000 AND median(salary_year_avg) <= 130000 THEN 'Medium Salary'
        ELSE 'Low Salary'
        END AS salary_level
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY 1;

--Handling NULL values
SELECT job_title_short, 
       salary_year_avg,
    CASE WHEN salary_year_avg IS NULL THEN 'Null entry'
        WHEN salary_year_avg > 130000 THEN 'High Salary'
        WHEN salary_year_avg > 100000 AND salary_year_avg <= 130000 THEN 'Medium Salary'
        ELSE 'Low Salary'
        END AS salary_level
FROM job_postings_fact
LIMIT 10;

-- Categorizing Categorical values
--E.g., clasiify the ;job_title' column value as:
-- 'Data Analyst', 'Data Engineer' and 'Data Scientist'

SELECT
    job_title,
    CASE WHEN job_title LIKE'%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE'%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        ELSE 'Data Scientist'
        END AS Categorized_title,

    job_title_short
FROM job_postings_fact
ORDER BY Random()
LIMIT 20;


/*Conditional Aggregation */
--Calculate Median Salaries for Different Buckets
SELECT
    job_title_short,
    COUNT(*) AS total_postings,
    MEDIAN(
        CASE
            WHEN salary_year_avg < 100000 THEN salary_year_avg
            END
    ) AS median_low_salary,
    MEDIAN(
        CASE
            WHEN salary_year_avg >= 100000 THEN salary_year_avg
            END
    ) AS median_high_salary,
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY 1;


/* Conditional Calculation
Compute a standardized salary using yearly salary and adjusted hourly salary (e.g., 2080 hours/year)
Categorize salaries into tires of:
    <75k low
    75k - 150k Medium
    >=150k High */
WITH salaries AS (
    SELECT
        job_title_short,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
        END AS standardized_salary
    FROM 
        job_postings_fact
    WHERE salary_year_avg IS NOT NULL OR  salary_hour_avg IS NOT NULL
)

SELECT 
    *,
    CASE 
        WHEN standardized_salary<75000 THEN 'low'
        WHEN standardized_salary<150000 THEN 'medium'
        ELSE 'High'
    END AS Categorized_salary
FROM salaries
LIMIT 10 ;
