/* Nested data allows to store multiple data types in a single column
5 common types */
-- 1. Array/list
SELECT [1, 2, 3];--INTEGER array/list
SELECT ['1', '2','3']; --VARCHAR array/list

--in duckdb docs we can see different Array functions which we can use
/*Lets first create a table with 1 column
Then convert it to ann array using Array_Agg function*/
WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
)
SELECT ARRAY_AGG(skill) AS skills_array
 FROM skills;
/*──────────────────┐
│   skills_array   │
│    varchar[]     │
├──────────────────┤
│ [sql, python, r] │
└──────────────────┘*/
--We could also use LIST() insetead of Array_agg
/*In the above created table the ARray/list is not ordered by
So if we want to select the first value
e.g. SELECT skills[1] it will
give any of the 3 skills and the output will hcange to the next run, 
So to make it an ordered array we have specify whole creating the Array
Lets update and wrap the 2nd part also within a CTE and then SELECT */

WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
    skills_array AS (
        SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
        FROM skills
    )
SELECT skills[1],
       skills[2],
       skills[3]
FROM skills_array;
/*───────────┬───────────┬───────────┐
│ skills[1] │ skills[2] │ skills[3] │
│  varchar  │  varchar  │  varchar  │
├───────────┼───────────┼───────────┤
│ python    │ r         │ sql       │
└───────────┴───────────┴───────────┘*/

--2. STRUCT
/* It has 2 parameters, filed and type*/
SELECT {skill: 'python', type: 'programming'};
/* main.struct_pack(skill := 'python', "type" := 'programming') │
│            struct(skill varchar, "type" varchar)             │
├──────────────────────────────────────────────────────────────┤
│ {'skill': python, 'type': programming}            */

/*Lets now like Array example,
CREATE a table and use a STRUCT function to
prepare a STRUCT  and also see how we can 
access the values, types from that STRUCT*/

WITH struct_table AS (
    SELECT STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) as S 
)
SELECT s.skill, s.type from struct_table;
/*─────────┬─────────────┐
│  skill  │    type     │
│ varchar │   varchar   │
├─────────┼─────────────┤
│ python  │ programming │
└─────────┴─────────────┘*/

/* So actually we can create a table from the struct values and types like below*/
WITH struct_skill_table AS (
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)

SELECT STRUCT_PACK(
    skill := skills,
    type := types
) 

FROM struct_skill_table;
/*struct_pack(skill := skills, "type" := "types") │
│      struct(skill varchar, "type" varchar)      │
├─────────────────────────────────────────────────┤
│ {'skill': python, 'type': programming}          │
│ {'skill': sql, 'type': query_language}          │
│ {'skill': r, 'type': programming}       */

--3. Array of Struct
SELECT [
    {skill : 'pythn', type:'prog'},  {skill : 'sql', type:'prog'} , {skill : 'r', type:'prog'} 
];
/*│ [{'skill': pythn, 'type': prog}, {'skill': sql, 'type': prog}, {'skill': r, 'type': prog}]│*/
--Lets use Array_Agg function to do this

WITH struct_skill_table AS (
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)

SELECT ARRAY_AGG (
    STRUCT_PACK(
    skill := skills,
    type := types
    ) 
)

FROM struct_skill_table;
/*array_agg(struct_pack(skill := skills, "type" := "types"))                              │
│                                       struct(skill varchar, "type" varchar)[]                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [{'skill': r, 'type': programming}, {'skill': sql, 'type': query_language}, {'skill': python, 'type': programming}] │*/

--NOw lets see how can we access the values, types
WITH struct_skill_table AS (
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
) ,
skills_array_struct AS ( --arapping inside another CTE
    SELECT ARRAY_AGG (
    STRUCT_PACK(
    skill := skills,
    type := types
    )
    ) array_struct
    FROM struct_skill_table
)
--Lets see if the table created properly
--SELECT * FROm skills_array_struct;
/*array_agg(struct_pack(skill := skills, "type" := "types"))                              │
│                                       struct(skill varchar, "type" varchar)[]                                       │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ [{'skill': r, 'type': programming}, {'skill': python, 'type': programming}, {'skill': sql, 'type': query_language}] │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘*/
--NOw time to access the value, type from this Array_STruct
SELECT  array_struct[1],
        array_struct[2],
        array_struct[3]
FROM   skills_array_struct
/*
┌────────────────────────────────────────┬────────────────────────────────────────┬───────────────────────────────────────┐
│            array_struct[1]             │            array_struct[2]             │            array_struct[3]            │
│ struct(skill varchar, "type" varchar)  │ struct(skill varchar, "type" varchar)  │ struct(skill varchar, "type" varchar) │
├────────────────────────────────────────┼────────────────────────────────────────┼───────────────────────────────────────┤
│ {'skill': python, 'type': programming} │ {'skill': sql, 'type': query_language} │ {'skill': r, 'type': programming}     │*/


--Now time to select the skill, values seperately

WITH struct_skill_table AS (
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
) ,
skills_array_struct AS ( --arapping inside another CTE
    SELECT ARRAY_AGG (
    STRUCT_PACK(
    skill := skills,
    type := types
    )
    ) array_struct
    FROM struct_skill_table
)

SELECT  array_struct[1].skill,
        array_struct[2].type,
        array_struct[3]
FROM   skills_array_struct; 
/*┌─────────────────────────┬──────────────────────────┬────────────────────────────────────────┐
│ (array_struct[1]).skill │ (array_struct[2])."type" │            array_struct[3]             │
│         varchar         │         varchar          │ struct(skill varchar, "type" varchar)  │
├─────────────────────────┼──────────────────────────┼────────────────────────────────────────┤
│ sql                     │ programming              │ {'skill': python, 'type': programming} │
└─────────────────────────┴──────────────────────────┴────────────────────────────────────────┘*/


--4. MAP: Its kind of a dictionary but less common

--5. JSON: It will be more used to receive json file and structure or organize the data inside database


/*Array final examples*/
SELECT  
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array 

FROM  job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd 
 ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
 ON sd.skill_id = sjd.skill_id 
WHERE sd.skills IS NOT NULL
AND jpf.salary_year_avg IS NOT NULL
GROUP BY ALL;
/*
 job_id  │    job_title_short    │ salary_year_avg │                                                    skills_array                                                    │
│  int32  │        varchar        │     double      │                                                     varchar[]                                                      │
├─────────┼───────────────────────┼─────────────────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 1211801 │ Senior Data Engineer  │        151782.0 │ [r, sql, scala, python, snowflake, aws, azure, gcp, databricks, ssrs, ssis, power bi, microstrategy, spark, kafka] │
│ 1211926 │ Data Engineer         │         70750.0 │ [sql, aws, azure, gcp, snowflake, redshift, databricks, spark]                                                     │
│ 1212402 │ Software Engineer     │        172000.0 │ [go, mysql]                                                                                                        │
│ 1212490 │ Data Scientist        │        141420.0 │ [go, mysql, gcp, bigquery]                                                                                         │
│ 1212716 │ Senior Data Analyst   │         95963.5 │ [sql, excel]                                                                                                       │
│ 1213203 │ Business Analyst      │        125000.0 │ [sql, assembly, python, r, azure, databricks, tableau, confluence, git] 
*/

--Let's practice analysisng this output or like access the array
--To do that we have to save this within a temporary table

CREATE OR REPLACE TEMP TABLE temp_table AS (
SELECT  
    jpf.job_id as job_id,
    jpf.job_title_short as JOB_TITLE,
    jpf.salary_year_avg as AVG_SALARY,
    ARRAY_AGG(sd.skills) AS skills_array 

FROM  job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd 
 ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
 ON sd.skill_id = sjd.skill_id 
WHERE sd.skills IS NOT NULL
AND jpf.salary_year_avg IS NOT NULL
GROUP BY ALL
);
SELECT * from temp_table;--Just to check if the table created properly

/*Now to access the array: If we see the previous output
the skills are arrayed in each row, to get
per row per skill we have to extract the skills per row individually
Because normal extraction would result like this */

SELECT skills_array[1],
       skills_array[2],
       skills_array[3],
FROM temp_table;
/* ─────────────────┬─────────────────┬─────────────────┐
│ skills_array[1] │ skills_array[2] │ skills_array[3] │
│     varchar     │     varchar     │     varchar     │
├─────────────────┼─────────────────┼─────────────────┤
│ scala           │ java            │ sql             │
│ sql             │ t-sql           │ python          │
│ python          │ sql             │ aws             │
│ go              │ apl             │ excel           │
│ go              │ java            │ python          │
│ scala           │ c#              │ java            │
│ python          │ scala           │ java            │
│ r               │ excel           │ NULL            │
│ sql             │ php             │ excel           │
│ python          │ java            │ sql             │
│ sql             │ power bi        │ excel     */

/* To break the arrays into rows 
we have to use the function UNNEST, e.g., */
SELECT UNNEST(skills_array)
FROM temp_table;
/*unnest(skills_array) │
│       varchar        │
├──────────────────────┤
│ scala                │
│ java                 │
│ sql                  │
│ nosql                │
│ aws                  │
│ kubernetes       */

/*NOw lets f=doa. real world job
Analyse median salary per skill*/
WITH flatten_tale AS (
    SELECT 
    job_id,
    JOB_TITLE,
    AVG_SALARY,
    UNNEST(skills_array) AS skill_name
    FROM temp_table
)
SELECT 
    skill_name,
    MEDIAN(AVG_SALARY)
FROM flatten_tale
GROUP BY ALL
ORDER BY MEDIAN(AVG_SALARY) DESC
LIMIT 20;
/*───────────────┬────────────────────┐
│  skill_name   │ median(AVG_SALARY) │
│    varchar    │       double       │
├───────────────┼────────────────────┤
│ fedora        │           182350.0 │
│ mongo         │           173500.0 │
│ debian        │           173000.0 │
│ haskell       │           165000.0 │
│ apl           │           160000.0 */



--FInal example ARRAY STRUCT
/* Lets first create one */

SELECT  
    jpf.job_id as job_id,
    jpf.job_title_short as JOB_TITLE,
    jpf.salary_year_avg as AVG_SALARY,
    ARRAY_AGG(
        STRUCT_PACK(
            skil_type:= sd.type,
            skill_name :=sd.skills
        )
    )
FROM  job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd 
 ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
 ON sd.skill_id = sjd.skill_id 
WHERE sd.skills IS NOT NULL
AND jpf.salary_year_avg IS NOT NULL
GROUP BY ALL;

/*job_id  │         JOB_TITLE         │ AVG_SALARY │                                                array_agg(struct_pack(skil_type := sd."type", skill_name := sd.skills))                                                │
│  int32  │          varchar          │   double   │                                                            struct(skil_type varchar, skill_name varchar)[]                                                            │
├─────────┼───────────────────────────┼────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ 1447217 │ Software Engineer         │   147500.0 │ [{'skil_type': databases, 'skill_name': postgresql}, {'skil_type': webframeworks, 'skill_name': fastapi}, {'skil_type': webframeworks, 'skill_name': express}, {'ski… │
│ 1447880 │ Data Engineer             │   204500.0 │ [{'skil_type': databases, 'skill_name': elasticsearch}, {'skil_type': programming, 'skill_name': python}, {'skil_type': programming, 'skill_name': sql}, {'skil_type… │
│ 1447979 │ Senior Data Engineer      │   253000.0 │ [{'skil_type': databases, 'skill_name': mysql}, {'skil_type': databases, 'skill_name': cassandra}, {'skil_type': cloud, 'skill_name': redshift}, {'skil_type'*/

--Cool, lets make a temp table so that we can practice accessing that array_struct
CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS (
    SELECT  
    jpf.job_id as job_id,
    jpf.job_title_short as JOB_TITLE,
    jpf.salary_year_avg as AVG_SALARY,
    ARRAY_AGG(
        STRUCT_PACK(
            skil_type:= sd.type,
            skill_name :=sd.skills
        )
    ) skill_array_struct
FROM  job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd 
 ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
 ON sd.skill_id = sjd.skill_id 
WHERE sd.skills IS NOT NULL
AND jpf.salary_year_avg IS NOT NULL
GROUP BY ALL
);
SELECT * FROM job_skills_array_struct LIMIT 10;--checking the output

--Now lets Analyze the median salary per type of the skills
--Lets frst see how UNNEST drive the result tobreak per row
SELECT
        job_id,
        JOB_TITLE,
        AVG_SALARY,
        UNNEST(skill_array_struct)
    FROM job_skills_array_struct;
/*job_id  │      JOB_TITLE       │ AVG_SALARY │              unnest(skill_array_struct)              │
│  int32  │       varchar        │   double   │    struct(skil_type varchar, skill_name varchar)     │
├─────────┼──────────────────────┼────────────┼──────────────────────────────────────────────────────┤
│  276480 │ Data Scientist       │   157500.0 │ {'skil_type': programming, 'skill_name': python}     │
│  276480 │ Data Scientist       │   157500.0 │ {'skil_type': programming, 'skill_name': r}          │
│  276480 │ Data Scientist       │   157500.0 │ {'skil_type': programming, 'skill_name': sql}        │
│  276480 │ Data Scientist       │   157500.0 │ {'skil_type': analyst_tools, 'skill_name': tableau}*/

/*SO now we have struct per row. and
now we can use the . notation to get per type or name*/
SELECT
        job_id,
        JOB_TITLE,
        AVG_SALARY,
        UNNEST(skill_array_struct).skil_type as skil_type,
        UNNEST(skill_array_struct).skill_name as skill_name
    FROM job_skills_array_struct;

--Now with CTE we can do the rest i.e., to get the median per skill type:
WITH new_temp AS (
    SELECT
        job_id,
        JOB_TITLE,
        AVG_SALARY,
        UNNEST(skill_array_struct).skil_type as skil_type,
        UNNEST(skill_array_struct).skill_name as skill_name
    FROM job_skills_array_struct
)
SELECT 
    skil_type,
    MEDIAN(AVG_SALARY)
FROM new_temp
GROUP BY skil_type
ORDER BY MEDIAN(AVG_SALARY) DESC;


SELECT user_id,
    