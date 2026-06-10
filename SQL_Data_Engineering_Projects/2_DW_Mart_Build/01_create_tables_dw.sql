-- Step 1: DW - Create start schema tables

DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS company_dim;





CREATE TABLE company_dim (
    company_id INTEGER PRIMARY KEY,
    name VARCHAR
);

CREATE TABLE skills_dim(
    skill_id INTEGER PRIMARY KEY,
    skill VARCHAR,
    type VARCHAR
);

CREATE TABLE job_postings_fact(
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER,
    job_title_short VARCHAR,
    job_title VARCHAR,
    job_location VARCHAR,
    job_via VARCHAR,
    job_schedule_type VARCHAR,
    job_work_from_home BOOLEAN,
    seacrh_location VARCHAR,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country VARCHAR,
    salary_rate VARCHAR,
    salary_year_avg DOUBLE,
    salary_hour_avg DOUBLE,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE skills_job_dim (
    job_id INTEGER,
    skill_id INTEGER,
    PRIMARY KEY(job_id, skill_id),
    FOREIGN KEY(skill_id) REFERENCES skills_dim(skill_id),
    FOREIGN KEY(job_id) REFERENCES job_postings_fact(job_id)
);

SELECT table_name
    FROm information_schema.tables
WHERE table_schema = 'main';


/*Initial set up: We have to add .gitignore file and create the git branches as per our git workflow:
GitIngonre file add and push to github as well:
git add .
git commit -m "add gitignore"
git push
Git branch creation:
develop branch → git switch -c develop/project-2
Like wise feature branch1: data-warehouse
Now time to run the above script to create tables--> duckdb dw_marts.duckdb -c ".read 01_create_tables_dw.sql"
*/