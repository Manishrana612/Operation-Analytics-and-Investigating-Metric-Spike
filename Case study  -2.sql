use operation_analytic;
create table users
(
user_id float,
created_at datetime,
company_id float,
language varchar(55),
activated_at datetime,
state varchar(55)
);
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';

LOAD DATA LOCAL INFILE 'C:/Users/karan/Desktop/Trainity/Table-1 users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table events
(user_id int,
occurred_at date,
 event_type varchar(55),
 event_name varchar(55),
 location varchar(55),
 device varchar(255),
 user_type int
);

LOAD DATA LOCAL INFILE 'C:/Users/karan/Desktop/Trainity/Table-2 events.csv'
INTO TABLE events
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from events;

create table emails
( user_id int,
 occurred_at date,
 action varchar(255),
 user_type int
);

LOAD DATA LOCAL INFILE 'C:/Users/karan/Desktop/Trainity/Table-3 email_events.csv'
INTO TABLE emails
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from emails;

/*A.User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.
	Your task: Calculate the weekly user engagement?*/

select 
extract(week from occurred_at) as weeknum,
count(distinct user_id)
from events
group by weeknum;

/* B. User Growth: Amount of users growing over time for a product.
      Your task: Calculate the user growth for product? */
# users growth = no of active user in per week 

select Extract(Day from created_at) AS day,
COUNT(*) AS all_users,
COUNT(CASE WHEN activated_at IS NOT NULL THEN user_id ELSE
NULL END) AS activated_users
FROM users 
WHERE created_at >= '01-01-13'
AND created_at < '31-08-14'
GROUP BY 1
ORDER BY 1;

/*D.Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.
   Your task: Calculate the weekly engagement per device?*/
   
   select
   extract(year from occurred_at) as year,
   extract(week from occurred_at) as week,
   device,
   count(distinct user_id)
   from events
   where event_type = 'engagement'
   group by 1,2,3;
   
   /* E. Email Engagement: Users engaging with the email service.
         Your task: Calculate the email engagement metrics?*/

      select 
      100.0* sum(case when email_cat='email_open' then 1 else 0 end )/sum(case when email_cat='email_sent' then 1 else 0 end ) as email_open_rate,
      100.0* sum(case when email_cat='email_click' then 1 else 0 end )/sum(case when email_cat='email_sent' then 1 else 0 end ) as email_clicked_rate
      from 
	  ( 
       select * , 
       case 
          when action in ('sent_weekly_digest','sent_reengagement_email')
          then 'email_sent'
          when action in ('email_open')
          then 'email_open'
          when action in ('email_clickthrough')
          then 'email_click'
          end as email_cat
          from emails
          ) a
