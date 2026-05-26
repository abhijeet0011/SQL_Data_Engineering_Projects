--Left right, inner, full join
--Left and inner joins are mostly used
--Left join takes all from Left table, and matching rows from right, raplace with null if no matching row found from the right table
--Right join: same but just true for the Right table
--Inner join: Takes only the matching rows from 2 tables
--FULL OUTER JOIN: Includes all entries and replace with null for the missing rows from either of the tables (combi of LEFT and RIGHT) 
        --Important to check the completeness of the database
SELECT jpf.*,
       CD.*
FROM
    job_postings_fact as jpf
LEFT JOIN company_dim AS CD
ON jpf.company_id = CD.company_id
LIMIT 10;

SELECT jpf.*,
       CD.*
FROM
    job_postings_fact as jpf
INNER JOIN company_dim AS CD -- We could also right only JOIN instead of INNER JOIN
ON jpf.company_id = CD.company_id
LIMIT 10;

SELECT jpf.*,
       CD.*
FROM
    job_postings_fact as jpf
FULL OUTER JOIN company_dim AS CD -- We could also right only FULL JOIN instead of FULL OUTER JOIN company_dim AS CD -- We could also right only FULL JOIN instead of INNER JOIN
ON jpf.company_id = CD.company_id
LIMIT 10;
