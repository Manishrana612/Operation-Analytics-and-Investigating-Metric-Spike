use operation_analytic;
alter table `case_study 1`
rename to job_data;

# Case Study (job_data)
/* A. Number of jobs reviewed: Amount of jobs reviewed over time.
      Your task: Calculate the number of jobs reviewed per hour per day for November 2020?*/
select * from job_data;
select ds,count(job_id) as jobs_per_day, sum(time_spent)/3600 as hours_spent 
from job_data
where ds >='01-11-20'  and ds <='30-11-20'
group by ds;   

/* B. Throughput: It is the no. of events happening per second.
      Your task: Let’s say the above metric is called throughput. Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why? */
 WITH CTE AS
 ( 
 SELECT 
 ds, 
 COUNT(job_id) AS num_jobs, 
 SUM(time_spent) AS total_time 
 FROM job_data
 WHERE event IN('transfer','decision') AND ds BETWEEN '01-11-20' AND '30-11-20' GROUP BY ds  )
 SELECT ds, ROUND(1.0*
 SUM(num_jobs) OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) / SUM(total_time)
 OVER (ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS throughput_7d
 FROM CTE ;     

/* Percentage share of each language: Share of each language for different contents.
   Your task: Calculate the percentage share of each language in the last 30 days?*/

WITH CTE AS (
SELECT
Language,
COUNT(job_id) AS num_jobs
FROM
job_data
WHERE
event IN('transfer','decision')
AND ds BETWEEN '01-11-20' AND '30-11-20'
GROUP BY
language
),
total AS (
SELECT
COUNT(job_id) AS total_jobs
FROM
job_data
WHERE
event IN('transfer','decision')
AND ds BETWEEN '01-11-20' AND '30-11-20'
GROUP BY
language
)
SELECT
language,
ROUND(100.0*num_jobs/total_jobs,2) AS percentage
FROM
CTE
CROSS JOIN
total
ORDER BY
percentage DESC;

/* D. Duplicate rows: Rows that have the same value present in them.
      Your task: Let’s say you see some duplicate rows in the data. How will you display duplicates from the table? */

WITH CTE AS ( 
SELECT 
 *, ROW_NUMBER() OVER (PARTITION BY ï»¿ds, job_id, 
actor_id) AS rownum 
FROM 
 job_data 
) 
DELETE 
FROM 
 CTE 
WHERE 
rownum > 1;
# there are no dublicate value present in data set 

