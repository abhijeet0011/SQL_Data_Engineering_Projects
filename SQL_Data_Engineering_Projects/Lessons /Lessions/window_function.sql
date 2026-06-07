/* Window function gives the facility to keep the data modelling and rows intact while doing advanced data analysis */

--count rows- Aggegation only
SELECT COUNT(*) FROM job_postings_fact;

--count rows WINDOW function
SELECT job_id,
       COUNT(*) OVER() 
    /*insdie over we can give what window we want to look at
    In this case we wnat to see row count per job_id so its just over()
    Here WINDOW function is allowing us to check row coun per job_id
    but keeping the original rowv values intact */
FROM
    job_postings_fact
    ORDER BY job_id;
/*output
 job_id  │ count() OVER () │
│  int32  │      int64      │
├─────────┼─────────────────┤
│    4593 │         1615930 │
│    4594 │         1615930 │
│    4595 │         1615930 */

--If we would use normal gorup by without the window function
SELECT job_id,
       COUNT(*) 
FROM
    job_postings_fact
    GROUP BY 1
    ORDER BY job_id;
/*output would be
job_id  │ count_star() │
│  int32  │    int64     │
├─────────┼──────────────┤
│    4593 │            1 │
│    4594 │            1 │
│    4595 │            1 │*/

--PARTION BYcan be used to like Group by function but within a WINDOW function
SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
    )
FROM
    job_postings_fact
    WHERE salary_hour_avg IS NOT NULL;
    /* job_id  │    job_title_short    │  salary_hour_avg   │ avg(salary_hour_avg) OVER (PARTITION BY job_title_short) │
│  int32  │        varchar        │       double       │                          double                          │
├─────────┼───────────────────────┼────────────────────┼──────────────────────────────────────────────────────────┤
│  250722 │ Data Analyst          │               46.0 │                                        37.28122352950212 │
│  250911 │ Data Engineer         │               10.0 │                                        56.68925185621045 │
│  251442 │ Data Scientist        │  50.83999633789063 │                                        49.80564666039103 │
│  251446 │ Data Scientist        │               29.0 │                                        49.80564666039103 │*/

--LET;s we also wnat to grup by inside by company id

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    company_id,
    AVG(salary_hour_avg) OVER (
        PARTITION BY (job_title_short, company_id)
    )
FROM
    job_postings_fact
    WHERE salary_hour_avg IS NOT NULL;--many company id level data was null

/*job_id  │    job_title_short    │  salary_hour_avg   │ company_id │ avg(salary_hour_avg) OVER (PARTITION BY main."row"(job_title_short, company_id)) │
│  int32  │        varchar        │       double       │   int32    │                                      double                                      │
├─────────┼───────────────────────┼────────────────────┼────────────┼──────────────────────────────────────────────────────────────────────────────────┤
│  250722 │ Data Analyst          │               46.0 │      12810 │                                                                            59.75 │
│  250911 │ Data Engineer         │               10.0 │       8637 │                                                               36.297175143398135 │
│  251442 │ Data Scientist        │  50.83999633789063 │      38008 │                                                                53.50624656677246 │*/

--ROW RANKs Using ORDER BY inside window function
SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    ) AS RANK_salary
FROM
    job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    ORDER BY salary_hour_avg; --This order by here is not necessary for this table but good to use for safety for complex scenarios

/*OUTPUT
─────────┬───────────────────────────┬─────────────────┬─────────────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ RANK_salary │
│  int32  │          varchar          │     double      │    int64    │
├─────────┼───────────────────────────┼─────────────────┼─────────────┤
│  256566 │ Data Analyst              │           391.0 │           1 │
│ 1004296 │ Data Scientist            │           250.0 │           2 │
│  110897 │ Data Analyst              │           242.5 │           3 │
│  646328 │ Data Scientist            │           237.5 │           4 │*/


--PARTITION BY and ORDER BY together
-- Ltes say we wnat to see AVG salary group by each title but order by job_posted_date
SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    )
FROM
    job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    ORDER BY job_title_short, job_posted_date;
    /*┌─────────────────────┬───────────────────┬────────────────────┬───────────────────────────────────────────────────────────────────────────────────┐
│   job_posted_date   │  job_title_short  │  salary_hour_avg   │ avg(salary_hour_avg) OVER (PARTITION BY job_title_short ORDER BY job_posted_date) │
│      timestamp      │      varchar      │       double       │                                      double                                       │
├─────────────────────┼───────────────────┼────────────────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ 2023-01-04 22:57:02 │ Business Analyst  │               17.0 │                                                                              17.0 │
│ 2023-01-04 23:44:05 │ Business Analyst  │               20.0 │                                                                              18.5 │
│ 2023-01-05 21:02:18 │ Business Analyst  │               35.0 │                                                                              24.0*/

--PARTITION BY and ORDER BY --Ranking by job_title_shoert
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK()  OVER(
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    )
FROM 
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY 
    salary_hour_avg DESC,
    job_title_short; 
/*┌─────────┬───────────────────────────┬─────────────────┬──────────────────────────────────────────────────────────────────────────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ rank() OVER (PARTITION BY job_title_short ORDER BY salary_hour_avg DESC) │
│  int32  │          varchar          │     double      │                                  int64                                   │
├─────────┼───────────────────────────┼─────────────────┼──────────────────────────────────────────────────────────────────────────┤
│  256566 │ Data Analyst              │           391.0 │                                                                        1 │
│ 1004296 │ Data Scientist            │           250.0 │                                                                        1 │
│  110897 │ Data Analyst              │           242.5 │                                                                        2 │*/

-/*RANK does not allow to add aggregation inside directly
for eample, if we wnat to get RANK ORER BY AVG(salary_hour_avg)
it will give error
to achieve this we just need to get the AVG data from another SELECTwhich means CTE/SUb query*/
WITH temp_table AS (
    SELECT
        job_title_short,
        COUNT(job_id) AS total_job_postings,
        AVG(salary_hour_avg) as avg_salary_hour_avg
    FROM
        job_postings_fact
    WHERE
        salary_hour_avg IS NOT NULL
    GROUP BY job_title_short
)

SELECT  
    job_title_short,
    total_job_postings,
    avg_salary_hour_avg,
    RANK() OVER(
        ORDER BY avg_salary_hour_avg DESC
    )
FROM temp_table;
/*───────────────────────────┬────────────────────┬─────────────────────┬─────────────────────────────────────────────────┐
│      job_title_short      │ total_job_postings │ avg_salary_hour_avg │ rank() OVER (ORDER BY avg_salary_hour_avg DESC) │
│          varchar          │       int64        │       double        │                      int64                      │
├───────────────────────────┼────────────────────┼─────────────────────┼─────────────────────────────────────────────────┤
│ Senior Data Engineer      │               1347 │   60.28611724573148 │                                               1 │
│ Senior Data Scientist     │               1088 │   56.96220155410907 │                                               2 │
│ Data Engineer             │               5962 │   56.68925185621045 │                                               3 */




/*DIfference between RANK and DENSE RANK
The basic difference is how they handle ties: RANK() skips subsequent numbers in the
 ranking sequence after a tie (e.g., 1, 2, 2, 4), whereas DENSE_RANK() 
leaves no gaps and assigns the next immediate sequential number (e.g., 1, 2, 2, 3)*/

--ROW NUMBER()
/* ============================================================================
   LESSON MODULE: Window Functions - ROW_NUMBER() Deep Dive
   COURSE: SQL for Data Engineering
   ============================================================================ */

/* ----------------------------------------------------------------------------
   WHAT IS ROW_NUMBER()?
   ----------------------------------------------------------------------------
   ROW_NUMBER() is a window function that assigns a unique, sequential integer 
   to each row, starting at 1. 
   
   Unlike RANK() or DENSE_RANK(), ROW_NUMBER() is strictly dictatorial: 
   IT NEVER ALLOWS TIES. Even if two rows share identical data values, 
   ROW_NUMBER() will forcefully assign them consecutive numbers (like 2 and 3).
*/

-- ============================================================================
-- THE PRACTICE WORKBENCH
-- ============================================================================

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    -- ROW_NUMBER tracks the physical sequence line within each job title bucket
    ROW_NUMBER() OVER(
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS row_num_sequence
FROM 
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY 
    job_title_short,
    row_num_sequence;

/* DATA ENGINEERING REAL-WORLD USE CASES:
   1. DEDUPLICATION (The #1 Production Use Case): 
      If an API pipeline accidentally inserts duplicate rows with identical 
      timestamps, you partition by the unique record keys, order by updated_at DESC, 
      and filter 'WHERE row_num_sequence = 1' to isolate the latest clean record.
      
   2. PAGINATION & BATCHING: 
      Splitting massive target tables into clean numerical chunks (e.g., records 1-100, 
      101-200) for downstream micro-batch processing applications.
*/


-- ============================================================================
-- SECTION 2: THE ARCHITECTURAL SHOWDOWN (ROW_NUMBER vs RANK vs DENSE_RANK)
-- ============================================================================

/*
   Let's visualize how they behave when they hit a tie (e.g., three Data Engineers 
   all making exactly $120,000):

   | Salary   | ROW_NUMBER() | RANK()   | DENSE_RANK() |
   | :---     | :---         | :---     | :---         |
   | $150,000 | 1            | 1        | 1            |
   | $120,000 | 2            | 2 (Tie)  | 2 (Tie)      |
   | $120,000 | 3            | 2 (Tie)  | 2 (Tie)      |
   | $120,000 | 4            | 2 (Tie)  | 2 (Tie)      |
   | $100,000 | 5            | 5 [Skips]| 3 [No Gaps]  |

   KEY DIFFERENCES SUMMARY:
   - ROW_NUMBER(): Sequential line count (1, 2, 3, 4, 5). Completely ignores ties.
   - RANK(): Competitor leaderboard (1, 2, 2, 2, 5). Shares ranks for ties, skips values next.
   - DENSE_RANK(): Dense leaderboard (1, 2, 2, 2, 3). Shares ranks for ties, never skips numbers.
*/


-- ============================================================================
-- CAN WE USE ROW_NUMBER() INSTEAD OF RANK()?
-- ============================================================================

/* YES, you can use ROW_NUMBER() instead of RANK() in production, but ONLY 
   when the business logic demands an ABSOLUTE UNIQUE WINNER.

   SCENARIO A: "Find the single highest-paying job posting per title"
   - Use ROW_NUMBER(). If 5 jobs tie for the highest salary, RANK() would return 
     all 5 rows with rank = 1. By filtering 'WHERE row_num_sequence = 1', 
     ROW_NUMBER() breaks the tie arbitrarily and returns exactly ONE clean row. 
     This is ideal for keeping data pipelines safe from unintentional row duplication.

   SCENARIO B: "Find all job titles that rank in the top 3 market salaries"
   - DO NOT use ROW_NUMBER(). If there is a tie for 3rd place, ROW_NUMBER() will 
     randomly eliminate some records from your report. In this scenario, you MUST 
     use DENSE_RANK() or RANK() to preserve business analytical accuracy.
*/

--Navigation function--> LAG and LEAD
--LAG()->Allows to compare a value with the oast value
--For example, Time based comparison of company yearly salary
SELECT
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS previous_posting_salary,

    salary_year_avg - LAG(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change

FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;
/*job_id  │ company_id │                             job_title                             │    job_title_short    │   job_posted_date   │ salary_year_avg │ previous_posting_salary │ salary_change │
│  int32  │   int32    │                              varchar                              │        varchar        │      timestamp      │     double      │         double          │    double     │
├─────────┼────────────┼───────────────────────────────────────────────────────────────────┼───────────────────────┼─────────────────────┼─────────────────┼─────────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist                                                    │ Data Scientist        │ 2024-01-30 14:28:11 │         75000.0 │                    NULL │          NULL │
│  995381 │       4593 │ Lead Data Engineer                                                │ Data Engineer         │ 2024-05-02 16:08:57 │        150000.0 │                 75000.0 │       75000.0 │
│  128388 │       4594 │ Data Scientist                                                    │ Data Scientist        │ 2023-02-14 06:02:22 │         90000.0 │                    NULL │          NULL │
│  134272 │       4594 │ AI/ML Health Data Scientist - Senior Consultant                   │ Senior Data Scientist │ 2023-02-16 11:06:48 │        112450.0 │                 90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist                                                    │ Data Scientist        │ 2023-02-21 07:23:56 │         90000.0 │                112450.0 │      -22450.0 │
│  159423 │       4594 │ Data Scientist - Analyst                                          │ Data Scientist        │ 2023-02-28 10:52:05 │         90000.0 │                 90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Consultant                                │ Data Scientist        │ 2023-03-02 09:49:47 │         90000.0 │                 90000.0 │           0.0 │
│  167525 │       4594 │ AI/ML Health Data Scientist - Senior Consultant                   │ Senior Data Scientist │ 2023-03-03 11:03:16 │        115000.0 │                 90000.0 │       25000.0 │
│  179599 │       4594 │ Data Analyst - Business Intelligence                              │ Data Analyst          │ 2023-03-09 09:00:18 │        129050.0 │                115000.0 │       14050.0 │
│  235865 │       4594 │ Cleared Data Scientist                                            │ Data Scientist        │ 2023-04-06 09:57:40 │        115000.0 │                129050.0 │      -14050.0 │
│  320213 │       4594 │ Data Scientist, Senior Consultant                                 │ Data Scientist        │ 2023-05-16 12:40:22 │         90000.0 │                115000.0 │      -25000.0 │
│  324613 │       4594 │ AI/ML Health Data Scientist - Senior Consultant                   │ Senior Data Scientist │ 2023-05-24 09:04:38 │        112450.0 │     */


--LEAD just do the same as LAG but gives the next value instead of previous
SELECT
    job_id,
    company_id,
    job_title,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LEAD(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS next_posting_salary,

    salary_year_avg - LEAD(salary_year_avg) OVER(
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS salary_change

FROM
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;
/*job_id  │ company_id │                             job_title                             │    job_title_short    │   job_posted_date   │ salary_year_avg │ next_posting_salary │ salary_change │
│  int32  │   int32    │                              varchar                              │        varchar        │      timestamp      │     double      │       double        │    double     │
├─────────┼────────────┼───────────────────────────────────────────────────────────────────┼───────────────────────┼─────────────────────┼─────────────────┼─────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist                                                    │ Data Scientist        │ 2024-01-30 14:28:11 │         75000.0 │            150000.0 │      -75000.0 │
│  995381 │       4593 │ Lead Data Engineer                                                │ Data Engineer         │ 2024-05-02 16:08:57 │        150000.0 │                NULL │          NULL │
│  128388 │       4594 │ Data Scientist                                                    │ Data Scientist        │ 2023-02-14 06:02:22 │         90000.0 │            112450.0 │      -22450.0 │
│  134272 │       4594 │ AI/ML Health Data Scientist - Senior Consultant                   │ Senior Data Scientist │ 2023-02-16 11:06:48 │        112450.0 │             90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist                                                    │ Data Scientist        │ 2023-02-21 07:23:56 │         90000.0 │             90000.0 │           0.0 │
│  159423 │       4594 │ Data Scientist - Analyst                                          │ Data Scientist        │ 2023-02-28 10:52:05 │         90000.0 │             90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Consultant                                │ Data Scientist        │ 2023-03-02 09:49:47 │         90000.0 │       */