--
SELECT CD.name as Company_name,
COUNT(jpf.*) as no_of_posting 
FROM job_postings_fact as jpf
LEFT JOIN company_dim as CD
ON jpf.company_id = CD.company_id
WHERE jpf.job_country = 'United States'
GROUP BY 1
HAVING COUNT(jpf.*)>3000
ORDER BY 2 DESC;

/*Order of execution behind the scen:
Step1: FROM, JOIN , ON -->Taking the tables needed
Step 2: WHERE
Step 3: Group by
Step 4: Having
Step 5: Select tables
Step 6: Order by
Step 8: LIMIT */

--Explain statements for investigate the order
EXPLAIN SELECT CD.name as Company_name,
COUNT(jpf.*) as no_of_posting 
FROM job_postings_fact as jpf
LEFT JOIN company_dim as CD
ON jpf.company_id = CD.company_id
WHERE jpf.job_country = 'United States'
GROUP BY 1
HAVING COUNT(jpf.*)>3000
ORDER BY 2 DESC;

--Explain ANalyse  shows more with timing per each block and total time tthe query took
EXPLAIN ANALYSE SELECT CD.name as Company_name,
COUNT(jpf.*) as no_of_posting 
FROM job_postings_fact as jpf
LEFT JOIN company_dim as CD
ON jpf.company_id = CD.company_id
WHERE jpf.job_country = 'United States'
GROUP BY 1
HAVING COUNT(jpf.*)>3000
ORDER BY 2 DESC;