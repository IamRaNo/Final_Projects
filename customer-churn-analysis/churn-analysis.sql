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
rename column `Payment Delay` to payment_delay,
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
sum(payment_delay is null) as payment_delay_null,
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
    row_number() over(partition by `age`,gender,tenure,frequency,support_calls,payment_delay,
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
    'payment_delay',min(payment_delay),max(payment_delay),round(avg(payment_delay),2),round(std(payment_delay),2),
    'spend',min(spend),max(spend),round(avg(spend),2),round(std(spend),2) 
from customers;
# There are no such numerical columns with wrong inputs

-- The conclusion about this dataset is 
--     1. Dataset contains 440k plus rows and 12 columns
--     2. There are 3 columns with text value and 9 columns with double value
--     3. There is no duplicate records with same id
--     4. There were one null valued column which is removed successfully
--     5. There are no duplicate id
--     6. There are no numerical columns with wrong data
--     7. There are no columns with a single value
--     8. The target column is churn column

-- ==========================================
-- Univariate Analysis on Each Column
-- ==========================================
select * from customers;


-- Information about the age column
select 
    min(age) as min_age,
    max(age) as max_age,
    round(avg(age),2) as average_age,
    round(std(age),2) as std_of_age
from customers;


-- Checking outlier ages
select 
    * 
from customers
    where age > (select avg(age)+2*std(age) from customers)
    or age < (select avg(age)-2*std(age) from customers);
# There are no such big outlier ages


-- Checking uniqe gender counts
select 
    gender,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by gender;
# There are few more males than females


-- Information about tenure column
select 
    min(tenure) as min_tenure,
    max(tenure) as max_tenure,
    round(avg(tenure),2) as avertenure_tenure,
    round(std(tenure),2) as std_of_tenure
from customers;


-- Checking outlier ages
select 
    * 
from customers
    where tenure > (select avg(tenure)+2*std(tenure) from customers)
    or tenure < (select avg(tenure)-2*std(tenure) from customers);


-- Checking outlier frequency
select 
    * 
from customers
    where frequency > (select avg(frequency)+2*std(frequency) from customers)
    or frequency < (select avg(frequency)-2*std(frequency) from customers);


-- Checking unique number of support calls
select 
    support_calls,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by support_calls
order by support_calls asc; 
# More than 50% people calls 4 or less number of times


-- Information about payment_delay column
select 
    min(payment_delay) as min_payment_delay,
    max(payment_delay) as max_payment_delay,
    round(avg(payment_delay),2) as averpayment_delay_payment_delay,
    round(std(payment_delay),2) as std_of_payment_delay
from customers;


-- Checking outlier payment delays
select * 
    from customers
        where payment_delay > (select avg(payment_delay)+2*std(payment_delay) from customers)
        or payment_delay < (select avg(payment_delay)-2*std(payment_delay) from customers);


-- Checking unique subscription counts
select 
    subscription,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by subscription
order by subscription asc;
# People are using all kind of subscriptions


-- Checking uniqe contract counts
select 
    contract,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by contract
order by contract asc;
# Less people with monthly contracts


-- Checking information about the spend column
select 
    min(spend) as min_spend,
    max(spend) as max_spend,
    round(avg(spend),2) as average_spend,
    round(std(spend),2) as std_of_spend
from customers;


-- Checking information about the last_interaction column
select 
    min(last_interaction) as min_last_interaction,
    max(last_interaction) as max_last_interaction,
    round(avg(last_interaction),2) as average_last_interaction,
    round(std(last_interaction),2) as std_of_last_interaction
from customers;


-- Checking unique counts of the churn column
select 
    churn,count(*) as `count`,concat(round(100*(count(*))/(select count(*) from customers),2),'%') as percentage
from customers
group by churn
order by churn asc;
# The churn rate is very high

-- ==========================================
-- Bivariate Analysis on Churn Columns */
-- ==========================================

