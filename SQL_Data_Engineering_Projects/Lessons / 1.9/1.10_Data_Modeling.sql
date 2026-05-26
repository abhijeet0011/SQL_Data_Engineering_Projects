--Test
Select job_id,
    job_title_short,
    salary_year_avg
FROM 
    job_postings_fact
LIMIT 10;

-- Information schema
SELECT * from information_schema.tables;-- Gives all tables info

-- Let's see specific table
SELECT * from information_schema.tables
WHERE table_catalog = 'data_jobs';

-- We can see table contraints like which are the keys, to get view of all clumns use Motherduckdb UI
SELECT * FROM information_schema.table_constraints
WHERE table_catalog = 'data_jobs';

--Another easy way
PRAGMA show_tables;

--Details view with PRAGMA
PRAGMA show_tables_expanded;

--Describe keyword
Describe job_postings_fact;


