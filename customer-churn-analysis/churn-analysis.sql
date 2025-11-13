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


-- Checking the data after renaming of columns
select * from customers;


-- Verifying the datatypes of the columns
select column_name,data_type
from information_schema.columns
where table_schema = database() and
table_name = 'customers';


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
    where id is null;
# There is one single column with all the null values,we will remove this row


-- Removing the null valued column
delete from customers
    where id is null;


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
select 
    'age',min(age),max(age),round(avg(age),2),round(std(age),2),
    'tenure',min(tenure),max(tenure),round(avg(tenure),2),round(std(tenure),2) ,
    'frequency',min(frequency),max(frequency),round(avg(frequency),2),round(std(frequency),2),
    'support_calls',min(support_calls),max(support_calls),round(avg(support_calls),2),round(std(support_calls),2),
    'spend',min(spend),max(spend),round(avg(spend),2),round(std(spend),2),
    'spend',min(spend),max(spend),round(avg(spend),2),round(std(spend),2) 
from customers;
# There are no such numerical columns with wrong inputs


/*
Univariate 
    Analysis on 
        Each Column
*/


select * from customers;


-- ==========================================
-- Univariate Analysis on Age Column
-- ==========================================


-- What is the statistics of the age column?
with duplicate as (
    select age,row_number() over(order by age) as rn,
    count(*) over() as total
    from customers
)
select (select age from duplicate where rn = floor(0.25*total)) as '25%',
(select age from duplicate where rn = floor(0.50*total)) as '50%',
(select age from duplicate where rn = floor(0.75*total)) as '75%',
(select age from duplicate where rn = floor(0.90*total)) as '90%',
(select round(avg(age),2) from duplicate)as average ,
(select min(age)from duplicate) as min_age,
(select max(age) from duplicate) as max_age,
(select round(std(age),2) from duplicate) as std_age;


-- What is the histogram of age based on age groups?
with age_bucket as
(select 
    case when age >= 18 and age < 25 then '1.young(18-25)'
            when age >= 25 and age < 35 then '2.mid(25-35)'
                when age >= 35 and age < 45 then '3.mid_aged(35-45)'
                    when age >= 45 and age < 55 then '4.upper_mid_aged(45-55)'
                        else '5.old_aged(60+)'
    end as buckets
    from customers
)
select buckets,count(buckets) as `count`
    from age_bucket
    group by buckets
    order by buckets asc;
# Most people are from 25 to 45 age groups


-- How many ages are statistically outlier in both sides?
with age_outs as
(select 
    case 
        when (tenure > (select avg(tenure)+1.5*std(tenure)from customers)) then 'upper_bound'
            when (tenure < (select avg(tenure)-1.5*std(tenure)from customers)) then 'lower_bound'
                else 'inside'
    end as age_outlier
from customers
)
select age_outlier,count(age_outlier) 
from age_outs
group by age_outlier;

-- ==========================================
-- Univariate Analysis on Gender Column
-- ==========================================


-- How gender is distributed?
select 
    gender,count(*) as `count`,
    concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by gender;
# There are few more males than females


-- ==========================================
-- Univariate Analysis on Tenure Column
-- ==========================================


-- What is the tenure statistics
with duplicate as (
    select tenure,row_number() over(order by tenure) as rn,
    count(*) over() as total
    from customers
)
select (select tenure from duplicate where rn = floor(0.25*total)) as '25%',
(select tenure from duplicate where rn = floor(0.50*total)) as '50%',
(select tenure from duplicate where rn = floor(0.75*total)) as '75%',
(select tenure from duplicate where rn = floor(0.90*total)) as '90%',
(select round(avg(tenure),2) from duplicate)as avg_tenure ,
(select min(tenure)from duplicate) as min_tenure,
(select max(tenure) from duplicate) as max_tenure,
(select round(std(tenure),2) from duplicate) as std_tenure;


-- What is the histogram of tenure based on tenure groups?
with tenure_bucket as
(select 
    case when tenure >= 0 and tenure < 2 then '1 Month'
            when tenure >= 2 and tenure < 13 then '1 Year'
                when tenure >= 13 and tenure < 24 then '2 Years'
                    when tenure >= 24 and tenure < 48 then '2-4 Years'
                        else '4+ Years'
    end as buckets
    from customers
)
select buckets,count(buckets) as `count`
    from tenure_bucket
    group by buckets
    order by count desc;
# Mostly tenure is 2 to 4 years.


-- ==========================================
-- Univariate Analysis on Frequency Column
-- ==========================================


-- What is the statistics of the frequency column?
with duplicate as (
    select frequency,row_number() over(order by frequency) as rn,
    count(*) over() as total
    from customers
)
select (select frequency from duplicate where rn = floor(0.25*total)) as '25%',
(select frequency from duplicate where rn = floor(0.50*total)) as '50%',
(select frequency from duplicate where rn = floor(0.75*total)) as '75%',
(select frequency from duplicate where rn = floor(0.90*total)) as '90%',
(select round(avg(frequency),2) from duplicate)as averfrequency ,
(select min(frequency)from duplicate) as min_frequency,
(select max(frequency) from duplicate) as max_frequency,
(select round(std(frequency),2) from duplicate) as std_frequency;


-- What is the histogram of frequenct based on frequency groups?
with frequency_bucket as
(select 
    case when frequency >= 0 and frequency < 10 then 'less'
            when frequency >= 10 and frequency < 20 then 'mid'
                else 'high'
    end as buckets
    from customers
)
select buckets,count(buckets) as `count`
    from frequency_bucket
    group by buckets
    order by count desc;
# Dataset is consist of high frequency customers more.


-- ==========================================
-- Univariate Analysis on Support_calls Column
-- ==========================================


-- What is the distribution of support calls?
select 
    support_calls,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by support_calls
order by support_calls asc;
# More than 50% people calls 4 or less number of times


-- ==========================================
-- Univariate Analysis on spend Column
-- ==========================================


-- What is the statistics of spend column?
with duplicate as (
    select spend,row_number() over(order by spend) as rn,
    count(*) over() as total
    from customers
)
select (select spend from duplicate where rn = floor(0.25*total)) as '25%',
(select spend from duplicate where rn = floor(0.50*total)) as '50%',
(select spend from duplicate where rn = floor(0.75*total)) as '75%',
(select spend from duplicate where rn = floor(0.90*total)) as '90%',
(select round(avg(spend),2) from duplicate)as averspend ,
(select min(spend)from duplicate) as min_spend,
(select max(spend) from duplicate) as max_spend,
(select round(std(spend),2) from duplicate) as std_spend;


-- What is the histogram of spend column
with spend_bucket as
(select 
    case when spend >=100 and spend < 500 then 'low'
            when spend >= 500 and spend < 900 then 'mid'
                when spend >= 900 and spend <= 1000 then 'high'
                    else 'others'
    end as buckets
    from customers
)
select buckets,count(buckets) as `count`
    from spend_bucket
    group by buckets
    order by count desc;
# There are more low valued customers than high valued ones.


-- How many spends are statistically outlier in both sides?
with spend_outlier as
(select 
    case 
        when (spend > (select avg(spend)+1.5*std(spend)from customers)) then 'upper_bound'
            when (spend < (select avg(spend)-1.5*std(spend)from customers)) then 'lower_bound'
                else 'inside'
    end as spend_outlier
from customers
)
select spend_outlier,count(spend_outlier) 
from spend_outlier
group by spend_outlier;
# More people with less spend


-- ==========================================
-- Univariate Analysis on Subscription Column
-- ==========================================


-- Checking unique subscription counts
select 
    subscription,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by subscription
order by subscription asc;
# People are using all kind of subscriptions


-- ==========================================
-- Univariate Analysis on Contract Column
-- ==========================================


-- Checking uniqe contract counts
select 
    contract,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by contract
order by contract asc;
# Less people with monthly contracts


-- ==========================================
-- Univariate Analysis on Last_interaction Column
-- ==========================================


-- What is the statistics of the Last_interaction column?
with duplicate as (
    select last_interaction,row_number() over(order by last_interaction) as rn,
    count(*) over() as total
    from customers
)
select (select last_interaction from duplicate where rn = floor(0.25*total)) as '25%',
(select last_interaction from duplicate where rn = floor(0.50*total)) as '50%',
(select last_interaction from duplicate where rn = floor(0.75*total)) as '75%',
(select last_interaction from duplicate where rn = floor(0.90*total)) as '90%',
(select round(avg(last_interaction),2) from duplicate)as averlast_interaction ,
(select min(last_interaction)from duplicate) as min_last_interaction,
(select max(last_interaction) from duplicate) as max_last_interaction,
(select round(std(last_interaction),2) from duplicate) as std_last_interaction;


-- What is the histogram of frequenct based on last_interaction groups?
with last_interaction_bucket as
(select 
    case when last_interaction >= 0 and last_interaction < 10 then 'less'
            when last_interaction >= 10 and last_interaction < 20 then 'mid'
                else 'high'
    end as buckets
    from customers
)
select buckets,count(buckets) as `count`
    from last_interaction_bucket
    group by buckets
    order by count desc;


-- ==========================================
-- Univarite Analysis on Churn Column
-- ==========================================


-- Checking unique counts of the churn column
select 
    churn,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by churn
order by churn asc;
# The churn rate is very high

/*
Bivariate 
    Analysis on 
        Churn Columns
*/


-- ==========================================
-- Bivariate Analysis on Churn vs Age
-- ==========================================


select churn,round(avg(age),2) as average_age from customers
group by churn;
# As we can see the average age differs in churn and not churned scenario.

with duplicate as
(select age,churn,
    case when age >= 18 and age < 25 then '1.young(18-25)'
            when age >= 25 and age < 35 then '2.mid(25-35)'
                when age >= 35 and age < 45 then '3.mid_aged(35-45)'
                    when age >= 45 and age < 55 then '4.upper_mid_aged(45-55)'
                        else '5.old_aged(60+)'
    end as 'age_bucket'
    from customers)
select age_bucket,churn,count(churn) as `count`,
round(100*(count(*)/sum(count (*)) over(partition by age_bucket)),2) as 'percentage'
from duplicate
group by age_bucket,churn
order by age_bucket asc;
# 60+ people will definitely churn.
# 25 - 45 age group have more staying rate than churn rate.