-- Active: 1745477253100@@127.0.0.1@3306@customer-churn-dataset
____________________________________________________________________

-- ==========================================
-- Basic information about the dataset
-- ==========================================


-- Checking the dataset
select * from customers_original;


-- Copying the data into some other table so that the main table remain intact in faulty cases
create table customers as
select * from customers_original;


-- Chcking the customers table
select * from customers;

-- Description of the customers table
describe customers;


-- Checking rows and column counts for this table
select 
    (select count(*) from customers) as `rows`,
    (select count(*) from information_schema.columns
        where table_schema=database()
        and table_name='customers') as `columns`;
# There are 440+ rows and 12 columns in this dataset


-- Checking duplicate values
with duplicate as (
select *,
    row_number() over(partition by `age`,gender,tenure,frequency,support_calls,spend,
        `subscription`,`contract`,spend,last_interaction,churn order by id asc) as rn
from customers)
select * from duplicate
where rn = 2;
# So there is no duplicate values in this table.


-- Checking if there is any duplicate id
select count(distinct id) as `unique`, count(id) as `total` 
    from customers;
# There is no duplicate id


-- How many unique values each column have?
select
    count(distinct gender) as gender,
    count(distinct frequency) as frequency,
    count(distinct support_calls) as support_calls,
    count(distinct `subscription`) as `subscription`,
    count(distinct `contract`) as `contract`,
    count(distinct churn) as churn
from customers;


-- Check if numerical columns have valid data or not
with cols as (
    select 'age' as col, age as val from customers
    union all
    select 'tenure', tenure from customers
    union all
    select 'frequency', frequency from customers
    union all
    select 'payment delay',payment_delay from customers
    union all
    select 'spend', spend from customers
    union all
    select 'last_interaction', last_interaction from customers
)
select 
    col,
    min(val) as min_val,
    max(val) as max_val,
    round(avg(val),2) as avg_val,
    round(std(val),2) as std_val
from cols
group by col;
# There are no such numerical columns with wrong inputs


-- Verifying the datatypes of the columns
describe customers;


-- Checking null values of each column
select sum(id is null) as id_null,
sum(age is null) as age_null,
sum(gender is null) as gender_null,
sum(tenure is null) as tenure_null,
sum(frequency is null) as frequency_null,
sum(support_calls is null) as support_calls_null,
sum(spend is null) as spend_null,
sum(subscription is null) as subscription_null,
sum(contract is null) as contract_null,
sum(spend is null) as spend_null,
sum(last_interaction is null) as last_interaction_null,
sum(churn is null) as churn_null 
from customers;
# There are single null values in each row, we have to check that value


-- Checking the null value rows
select * 
    from customers
    where id is null
    or age is null
    or gender is null
    or tenure is null
    or frequency is null
    or support_calls is null
    or payment_delay is null
    or `subscription` is null
    or `contract` is null
    or spend is null
    or last_interaction is null
    or churn is null;
# There is one single column with all the null values,we will remove this row


-- ==========================================
-- Fixing the dataset
-- ==========================================


-- Renaming columns of the customers table
alter table customers
rename column CustomerId to id,
rename column Age to age,
rename column Gender to gender,
rename column Tenure to tenure,
rename column `Usage Frequency` to frequency,
rename column `Support Calls` to support_calls,
rename column `Payment Delay` to spend,
rename column `Subscription Type` to `subscription`,
rename column `Contract Length` to `contract`,
rename column `Total Spend` to spend,
rename column `Last Interaction` to `last_interaction`,
rename column Churn to churn;


-- Removing the null valued column
delete from customers
    where id is null;


select * from customers;


-- ==========================================
-- Adding columns to the dataset
-- ==========================================

-- Adding age bins column
alter table customers
add column age_bins varchar(100);


-- Filling age bins column
update customers
set age_bins = 
    case 
        when age >=18 and age<=25 then '18-25'
        when age >25 and age <= 35 then '25-35'
        when age > 35 and age <= 45 then '35-45'
        when age > 45 and age <= 55 then '45-55'
        when age > 55 then '55+'
        else 'invalid'
    end;


-- Adding tenure bins column
alter table customers
add column tenure_bins varchar(100);


-- Adding values to the tenure bins column
update customers
set tenure_bins=
    case 
        when tenure < 7 then '6 Months'
        when tenure < 13 then '1 Year'
        when tenure < 25 then '2 Years'
        when tenure < 61 then '2+ years'
        else 'invalid'
    end;


-- Adding frequency bins column
alter table customers
add column frequency_bins varchar(100);


-- Adding values to frequency bins
update customers
set frequency_bins = 
    case
        when frequency < 6 then 'less'
        when frequency < 16 then 'moderate'
        when frequency < 31 then 'high'
        else 'invalid'
    end;


-- Adding payment delay bins
alter table customers
add column payment_delay_bins varchar(100);


-- Adding values to payment_delay bins column
update customers
set payment_delay_bins = 
    case
        when payment_delay < 8 then 'week'
        when payment_delay < 16 then 'half month'
        when payment_delay < 31 then 'over half month'
        else 'invalid'
    end;


-- Adding spend bins column
alter table customers
add column spend_bins varchar(100);


-- Adding values in spend bins column
update customers
set spend_bins = 
    case
        when spend < 401 then 'low(<400)'
        when spend < 701 then 'mid(400-700)'
        when spend < 1001 then 'high(700-1000)'
        else 'invalid'
    end;


-- Adding last interaction bins columns
alter table customers
add column last_interaction_bins varchar(100);


-- Adding values in last interaction bins column
update customers
set last_interaction_bins =
    case
        when last_interaction < 11 then '0-10'
        when last_interaction < 16 then '10-15'
        when last_interaction < 31 then '15-30'
        else 'invalid'
    end;

-- ==========================================
-- Univariate Analysis
-- ==========================================


-- Numerical column stats all together
with cols as (
    select 'age' as col, age as val from customers
    union all
    select 'tenure', tenure from customers
    union all
    select 'frequency', frequency from customers
    union all
    select 'payment delay',payment_delay from customers
    union all
    select 'spend', spend from customers
    union all
    select 'last_interaction', last_interaction from customers
)
select 
    col,
    min(val) as min_val,
    max(val) as max_val,
    round(avg(val),2) as avg_val,
    round(std(val),2) as std_val
from cols
group by col;


-- Categorical columns
select gender,
    count(gender) as `count`, 
    concat(round(100*(count(gender)/(select count(*) from customers)),2),"%") as percentage
from customers
group by gender;
# More males than females


select support_calls,
    count(support_calls) as `count`, 
    concat(round(100*(count(support_calls)/(select count(*) from customers)),2),"%") as percentage
from customers
group by support_calls
order by support_calls;
# Half of the users calls 4 or less than 4 times

select subscription,
    count(subscription) as `count`, 
    concat(round(100*(count(subscription)/(select count(*) from customers)),2),"%") as percentage
from customers
group by subscription;
# Subscription type is nicely spreaded, people are using all kind of subscriptions


select contract,
    count(contract) as `count`, 
    concat(round(100*(count(contract)/(select count(*) from customers)),2),"%") as percentage
from customers
group by contract;
# Mostly people are using long term contracts


select churn,
    count(churn) as `count`, 
    concat(round(100*(count(churn)/(select count(*) from customers)),2),"%") as percentage
from customers
group by churn;
# Churn % is higher than stay percentage, business is at risk


select age_bins,
    count(age_bins) as `count`, 
    concat(round(100*(count(age_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by age_bins
order by age_bins;
# Most of the customers are of mid aged groups, there are less customers who are young and older


select tenure_bins,
    count(tenure_bins) as `count`, 
    concat(round(100*(count(tenure_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by tenure_bins;
# More than 60% customers are old customers, approx 10% customers are new


select frequency_bins,
    count(frequency_bins) as `count`, 
    concat(round(100*(count(frequency_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by frequency_bins;
# Usage of this service is moderate to high, less people with less frequency, good for business


select payment_delay_bins,
    count(payment_delay_bins) as `count`, 
    concat(round(100*(count(payment_delay_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by payment_delay_bins;
# There is not such big difference but most of the payments are delayed by more than half a month


select spend_bins,
    count(spend_bins) as `count`, 
    concat(round(100*(count(spend_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by spend_bins;
# Users are spending more to medium...few with less spend


select last_interaction_bins,
    count(last_interaction_bins) as `count`, 
    concat(round(100*(count(last_interaction_bins)/(select count(*) from customers)),2),"%") as percentage
from customers
group by last_interaction_bins;
# customers in the transition phase is less.


-- ==========================================
-- Bivariate Analysis
-- ==========================================


-- With Cat to Num columns
select churn,  
    min(age) as min_age,
    max(age) as max_age,
    round(avg(age),2) as average_age, 
    round(std(age),2) as std_age
from customers
group by churn;
# There are no customers over 50 that stayed.
# Churned customers are spreaded and not churned customers are clustered compared to churned.
# Age does not matter for young users to churn or stay but this is a strong measure for old people.


select churn,  
    min(tenure) as min_tenure,
    max(tenure) as max_tenure,
    round(avg(tenure),2) as avertenure_tenure, 
    round(std(tenure),2) as std_tenure
from customers
group by churn;
# There is no specific distinction can be made based on tenure colum







select * from customers;


alter table customers
add column age_group;
