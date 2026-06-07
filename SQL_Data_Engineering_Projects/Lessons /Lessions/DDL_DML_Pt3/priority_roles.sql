/*Let's first create the jobs_mart.staging.priority_roles table which is one of ythe source table
This table was created before in our previous example but recreateing it as we want to automate within a script for this table creation*/

CREATE OR REPLACE TABLE staging.priority_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

INSERT INTO staging.priority_roles (role_id, role_name, priority_lvl)
VALUES 
 (1, 'Data Engineer', 2),
 (2, 'Senior Data Engineer', 1),
 (3, 'Software Engineer', 3);

 SELECT * FROM staging.priority_roles;
