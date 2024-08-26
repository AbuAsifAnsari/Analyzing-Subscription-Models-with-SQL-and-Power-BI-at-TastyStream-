select * from Subscriptions

select * from plans




Q.01 How many customers has Foodie-Fi ever had?

select distinct(count(Customer_id)) as number_cus
  from Subscriptions
  
Q.02  What is the monthly distribution of trial plan start_date values for our dataset? — Use the start of the month as the
group by value.

select month(Start_date) as months,
monthname(Start_date) as month_name, count(plan_id)
from Subscriptions
where plan_id = 0
group by 1, 2
order by 1

select 
month(Start_date) as months,
monthname(Start_date) as month_name, p.plan_name, count(s.plan_id)
from 
Subscriptions as s
join 
plans as p
on s.plan_id = p.plan_id
where s.plan_id = 0
group by 1, 2, 3
order by 1

Q.03 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for
each plan_name.

select
p.plan_id, p.plan_name, count(*) as cnt
from 
Subscriptions as s
join 
plans as p
on s.plan_id = p.plan_id
where Start_date >= '2021-01-01'
group by  1, 2 
order by 1

Q.04 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?


select count(Customer_id) as churn_cnt,
round(100 * count(Customer_id) /(select count(distinct Customer_id) from Subscriptions),1) as churn_per
from 
Subscriptions
where plan_id = 4 

Q.5  How many customers have churned straight after their initial free trial? — what percentage is this rounded to the
nearest whole number?

with a as
(select
s.Customer_id, s.Plan_id, p.Plan_Name,
row_number() over (partition by Customer_id order by Plan_id) as rank_
from 
Subscriptions as s
join 
plans as p  
on s.plan_id = p.plan_id)

select 
count(Customer_id) as cnt, 
round(100 * count(Customer_id) / (select count(distinct (Customer_id)) from a),0) as perce
from a
where plan_id = 4 and rank_ = 2


Q. 06 What is the number and percentage of customer plans after their initial free trial?

with a as 
(select 
customer_id, plan_id, lead(plan_id, 1) over (partition by customer_id order by plan_id) as next_plan
from 
Subscriptions)

select 
next_plan,
count(customer_id) as cus_num,
100 * count(customer_id) / (select count(distinct customer_id) from Subscriptions) as perce
from a
where next_plan is not null and plan_id = 0
group by 1
order by 1

Q.7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020–12–31?

with a as 
(select *,
lead(Start_date,1) over (partition by Customer_id order by Start_date) as next_date
from Subscriptions
where 
Start_date <= '2020-12-31'),

b as
(select 
plan_id,
count(distinct Customer_id) as cnt
from a
where 
(next_date is not null and (Start_date < '2020-12-31' and next_date > '2020-12-31'))
or (next_date is null and Start_date < '2020-12-31')
group by plan_id)


select 
plan_id , cnt, 
round(100 * cnt / (select count(distinct customer_id) from Subscriptions),1) as perce
from b
group by 1, 2
order by 1


Q.8 How many customers have upgraded to an annual plan in 2020?

select  
count(distinct customer_id) as cnt
from 
Subscriptions 
where 
plan_id = 3  and Start_date <= '2020-12-31'

select 
count(distinct customer_id) as cnt
from 
Subscriptions 
where 
plan_id = 3  and year(Start_date) <= '2020'

Q.9 How many days on average does it take a customer to an annual plan from the day they join Foodie-Fi?

with a as
(select 
customer_id , Start_date as trial_date
from 
Subscriptions 
where 
plan_id = 0),

b as
(select 
customer_id , Start_date as annual_date
from 
Subscriptions 
where 
plan_id = 3)

select round(avg(annual_date - trial_date),0) as avgr
from 
a join b
on a.customer_id = b.customer_id


Q.10  Can you further breakdown this average value into 30-day periods? (i.e. 0–30 days, 31–60 days etc)


with a as
(select customer_id , start_date  as trial_date
from Subscriptions 
where 
plan_id = 0),

b as
(select customer_id , start_date  as annual_date
from Subscriptions 
where 
plan_id = 3)

select 
 CASE 
        WHEN DATEDIFF(b.annual_date, a.trial_date) BETWEEN 0 AND 30 THEN '0-30 days'
        WHEN DATEDIFF(b.annual_date, a.trial_date) BETWEEN 31 AND 60 THEN '31-60 days'
        WHEN DATEDIFF(b.annual_date, a.trial_date) BETWEEN 61 AND 90 THEN '61-90 days'
        WHEN DATEDIFF(b.annual_date, a.trial_date) BETWEEN 91 AND 120 THEN '91-120 days'
        ELSE '121+ days' end bucket,
count(*) as cnt
from a 
join b 
on a.customer_id = b.customer_id
group by bucket
order by 2


Q. 11 How many customers downgraded from a pro-monthly to a basic monthly plan in 2020?

with a as
(select 
customer_id, plan_id, start_date,
lead(plan_id,1) over (partition by customer_id order by plan_id) as next_plan
from 
Subscriptions)

select count(*) from a 
where 
start_date <= '2020-12-31' 
and plan_id = 2 and next_plan = 1



