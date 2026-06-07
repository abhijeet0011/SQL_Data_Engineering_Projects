--DATE
--See what we have in the table
SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

--Let's explore different DATE functions
SELECT job_posted_date,
job_posted_date :: DATE AS date, --remember this :: is the CAST function
job_posted_date :: TIME AS time,
job_posted_date :: TIMESTAMP AS timestamp,
job_posted_date :: TIMESTAMPTZ AS timestampTZ --adding with  '-'  the timezone, since our values in job_posted_date has the data type TIMESTAMP and does not have timezone info, the output will be auto set to the location of the querry runner 
FROM job_postings_fact
LIMIT 10;

SELECT 
    job_posted_date,
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(DAY FROM job_posted_date) AS job_posted_day,
    EXTRACT(HOUR FROM job_posted_date) AS job_posted_hour,
    EXTRACT(HOUR FROM job_posted_date) AS job_posted_hour,
    EXTRACT(SECOND FROM job_posted_date) AS job_posted_second
    FROM job_postings_fact
LIMIT 10;

--Aggregation: E.g., show the no. of job_postings DE monthly basis
SELECT
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS no_of_job_postings
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP By 1,2
LIMIT 10;

/*DATE TRUNC: This will truncate as per the precision defined e.g., year, moth etc
E.g., if we truncate with year the month, truncation will happen after month and so day values will be set as 01 and the time values will be 0,
if we trunate per month,  */
SELECT job_posted_date,
    DATE_TRUNC('year', job_posted_date) AS truncated_year,
    DATE_TRUNC('quarter', job_posted_date) AS truncated_quarter,
    DATE_TRUNC('month', job_posted_date) AS truncated_month,
    DATE_TRUNC('day', job_posted_date) AS truncated_day,
    DATE_TRUNC('week', job_posted_date) AS truncated_yweek
    --see more for duckdb docs
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;

--Practice: see the monthly no. of DE job postings from 2024
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posting_month,
    COUNT(job_id) AS no_of_job_postings
FROM
    job_postings_fact
WHERE 
    job_title_short = 'Data Engineer'
    AND EXTRACT (YEAR FROM job_posted_date) = 2024
GROUP BY DATE_TRUNC('month', job_posted_date);

--AT TIME ZONE--> This convets to the specified time zone, more in duckdb docs
SELECT 
    '2024-06-01 00:00:00+00'::TIMESTAMPTZ,--without convertion -->Output 2024-06-01 02:00:00+02 , so the hour has changed automatically to my current timezone (CET), since the column is of TIMESTAMP data type and not TIMESTAMPTZ which would have TZ part added to it
    '2024-06-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'CET', --> output-->2024-06-01 02:00:00 , so its just the same output as above since i chose to convert to CET
    '2024-06-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'CST';-->output  2024-05-31 19:00:00  , hour changed as converted to CST time zone

/* So in real rile of tis is the situation that
we don have TZ added to our column but we know at which timezone
the data belongs to, we can convert it to the desired timezone */
--Let's say we know the data is from 'UTC' and we want to convert it to 'EST'
SELECT 
    job_posted_date AS original_value,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' --so here "AT TIME ZONE 'UTC' " part is defining which timzone the data belongs to
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;
 /*
─────────────────────┬─────────────────────────────────────────────────────────────┐
│   original_value    │ main.timezone('EST', main.timezone('UTC', job_posted_date)) │
│      timestamp      │                          timestamp                          │
├─────────────────────┼─────────────────────────────────────────────────────────────┤
│ 2024-03-23 16:31:18 │ 2024-03-23 11:31:18                                         │
│ 2025-01-23 20:52:13 │ 2025-01-23 15:52:13                                         │
│ 2023-07-23 20:19:02 │ 2023-07-23 15:19:02                                         │
│ 2025-03-23 16:38:37 │ 2025-03-23 11:38:37                                         │
│ 2024-07-19 12:06:29 │ 2024-07-19 07:06:29          
 */
    

--Practice prob: Provide no of job posts in NY per NY NY timezone hour
SELECT
    EXTRACT(HOUR FROM job_posted_date) AS orginal_value,
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS converted_NY_job_posting_hour,
    COUNT(*) as no_of_job_post
FROM
    job_postings_fact
WHERE 
    job_location LIKE 'New York, NY'
GROUP BY 1, 2
LIMIT 10;

/*
┌───────────────┬───────────────────────────────┬────────────────┐
│ orginal_value │ converted_NY_job_posting_hour │ no_of_job_post │
│     int64     │             int64             │     int64      │
├───────────────┼───────────────────────────────┼────────────────┤
│            17 │                            12 │           1126 │
│            19 │                            14 │            817 │
│            23 │                            18 │            686 │
│            12 │                             7 │           1236 │
│             5 │                             0 │            150 │
│            22 │                            17 │            658 │
│            10 │                             5 │           1238 │
│            20 │                            15 │            702 │
│             8 │                             3 │            864 │
│            15 │                            10 │           1011 │
└───────────────┴───────────────────────────────┴────────────────┘
*/
--INTERVAL is another useful function, Duckdb docs has more


