-- Active: 1745477253100@@127.0.0.1@3306@cab
select * from `train`;

-- ==========================================
-- Information about the data and major fixing
-- ==========================================
describe train;

-- Problems with the data 
-- 1.vendor id is in text format
-- 2.driver tip and mta tax is in text format
-- 3.pickuptime and drop time is in text format.
-- 4.toll amount is in text format
-- 5.extra charge,improvement charge, total amount is in text format
-- column names are in bad format

select count(*) as row_count,
   ( select count(*) from information_schema.columns
        where table_schema = database() and
        table_name = 'train') as column_count
from train;
# Rows - 1048575 , Columns - 17

select count(distinct id) from train;
# There is no column with duplicate id

create table cabs as
    select * from train;

select * from cabs;

-- Rename all the columns
alter table cabs
change column `ID` id bigint,
change column `vendor+af8-id` vendor_id text,
change column `pickup+af8-loc` pickup_loc double,
change column `drop+af8-loc` drop_loc double,
change column `driver+af8-tip` driver_tip text,
change column `mta+af8-tax` mta_tax text,
change column `pickup+af8-time` pick_time text,
change column `drop+af8-time` drop_time text,
change column `num+af8-passengers` passenger_nums double,
change column `toll+af8-amount` toll_amount text,
change column `payment+af8-method` payment_method double,
change column `rate+af8-code` rate_code double,
change column `stored+af8-flag` stored_flag text,
change column `extra+af8-charges` extra_charges text,
change column `improvement+af8-charge` improvement_charge text,
change column `total+af8-amount` total_amount text;

select * from cabs;

-- Fix Wrong values and filling those with null values, and changing the data type
update cabs
set driver_tip = null
where driver_tip not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify driver_tip double;

update cabs
set mta_tax = null
where mta_tax not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify mta_tax double;

update cabs
set pick_time = str_to_date(pick_time,'%m/%d/%Y %h:%i:%s %p'),
    drop_time = str_to_date(drop_time,'%m/%d/%Y %h:%i:%s %p');

alter table cabs
modify drop_time datetime,
modify pick_time datetime;

update cabs
set toll_amount = null
where toll_amount not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify toll_amount double;

update cabs
set extra_charges = null
where extra_charges not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify extra_charges double;

update cabs
set improvement_charge = null
where improvement_charge not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify improvement_charge double;

update cabs
set total_amount = null
where total_amount not regexp '^[0-9]+(\.[0-9]+)?$';

alter table cabs
modify total_amount double;

alter table cabs
modify payment_method varchar(50);

update cabs
set payment_method = 
    case 
    when payment_method = 1 then 'credit card'
    when payment_method = 2 then 'cash'
    when payment_method = 3 then 'free ride'
    when payment_method = 4 then 'disputed'
    when payment_method = 5 then 'unknown'
    when payment_method = 6 then 'void trip'
    end;

alter table cabs
modify rate_code varchar(50);

update cabs
set rate_code = 
    case
        when rate_code = 1 then 'standard'
        when rate_code = 2 then 'airport'
        when rate_code = 3 then 'connaught place'
        when rate_code = 4 then 'noida'
        when rate_code = 5 then 'negotiated fare'
        when rate_code = 6 then 'pooled ride'
        else 'others'
    end;

select * from cabs;

with duplicate as
(select *, 
row_number() over(partition by vendor_id,pickup_loc,drop_loc,driver_tip,mta_tax,distance,pick_time,drop_time,passenger_nums,toll_amount,
                                payment_method,rate_code,stored_flag,extra_charges,improvement_charge,total_amount) as rn
from cabs)
select * from duplicate
where rn > 1;

-- Checking unique values of each categorical type columns
select count(distinct vendor_id) as vendor_id,
    count(distinct pickup_loc) as pickup_loc,
    count(distinct drop_loc) as drop_loc,
    count(distinct mta_tax) as mta_tax,
    count(distinct passenger_nums) as passenger_nums,
    count(distinct toll_amount) as toll_amount,
    count(distinct payment_method) as payment_method,
    count(distinct rate_code) as rate_code,
    count(distinct stored_flag) as stored_flag,
    count(distinct extra_charges) as extra_charges,
    count(distinct improvement_charge) as improvement_charge
from cabs;

select * from cabs;

-- Check null values of each column
select sum(id is null) as id,
sum(vendor_id is null) as vendor_id,
sum(pickup_loc is null) as pick_loc,
sum(drop_loc is null) as drop_loc,
sum(driver_tip is null) as driver_tip,
sum(mta_tax is null) as mta_tax,
sum(distance is null) as distance,
sum(pick_time is null) as pick_time,
sum(drop_time is null) as drop_time,
sum(passenger_nums is null) as passanger_num,
sum(toll_amount is null) as toll_amount,
sum(payment_method is null ) as payment_method,
sum(rate_code is null) as rate_code,
sum(stored_flag is null) as stored_flag,
sum(extra_charges is null) as extra_charges,
sum(improvement_charge is null) as improvement_charge,
sum(total_amount is null) as total_amount
from cabs;

--Checking some of the null valued rows where null count is low
select * from cabs
where 
pickup_loc is null or 
drop_loc is null or
driver_tip is null or
distance is null or
pick_time is null or
drop_time is null or
passenger_nums is null or
toll_amount is null or
payment_method is null or
stored_flag is null;
# Id 599121 have most columns null and unknown vendor id too, the whole row needs to be removed
# Other problematic columns have some specific values which are important for analysis so we can not remove those values.
# Need to fill those value using some imputation methods

-- Delete disputed row
delete from cabs
    where `id`= 599121;

select * from cabs;

-- ==========================================
-- Univariate analysis of the data and remaining cleanings
-- ==========================================

with duplicate as(
    select 'driver_tip' as col, driver_tip as val from cabs
    union all
    select 'distance',distance from cabs
    union all
    select 'toll_amount',toll_amount from cabs
    union all
    select 'extra_charges',extra_charges from cabs
    union all
    select 'total_amount',total_amount from cabs
) select 
col,
max(val) as max_val, 
min(val) as min_val, 
round(avg(val),2) as average_val
from duplicate
group by col;
# Minimum value of these columns are 0 and  
# Mean is also close to 0 than max...we will impute the nulls with 0

-- Filling out null values with 0
update cabs
set driver_tip = 0
where driver_tip is null;

update cabs
set distance = 0
where distance is null;

update cabs
set toll_amount = 0
where toll_amount is null;

update cabs
set extra_charges = 0
where extra_charges is null;

update cabs
set total_amount = 0
where total_amount is null;

with duplicate as (
    select 'mta_tax' as col,mta_tax as val from cabs
    union all
    select 'improvement_charge', improvement_charge from cabs
) select col,val,count(val) as `count`
from duplicate 
group by col,val;
# As we have seen, both these tax have values as 0.5 and 0.3 as highest count, we will replace nulls using those

update cabs
set mta_tax = 0.5
where mta_tax is null;

update cabs
set improvement_charge = 0.3
where improvement_charge is null;

select * from cabs;

-- Checking null values again
select sum(id is null) as id,
sum(vendor_id is null) as vendor_id,
sum(pickup_loc is null) as pick_loc,
sum(drop_loc is null) as drop_loc,
sum(driver_tip is null) as driver_tip,
sum(mta_tax is null) as mta_tax,
sum(distance is null) as distance,
sum(pick_time is null) as pick_time,
sum(drop_time is null) as drop_time,
sum(passenger_nums is null) as passanger_num,
sum(toll_amount is null) as toll_amount,
sum(payment_method is null ) as payment_method,
sum(rate_code is null) as rate_code,
sum(stored_flag is null) as stored_flag,
sum(extra_charges is null) as extra_charges,
sum(improvement_charge is null) as improvement_charge,
sum(total_amount is null) as total_amount
from cabs;

-- Count of distinct values in each column
select count(distinct vendor_id) as vendor_id,
    count(distinct pickup_loc) as pickup_loc,
    count(distinct drop_loc) as drop_loc,
    count(distinct driver_tip) as driver_tip,
    count(distinct mta_tax) as mta_tax,
    count(distinct passenger_nums) as passenger_nums,
    count(distinct distance) as distance,
    count(distinct pick_time) as pick_time,
    count(distinct drop_time) as drop_time,
    count(distinct passenger_nums) as passenger_nums,
    count(distinct toll_amount) as toll_amount,
    count(distinct payment_method) as payment_method,
    count(distinct rate_code) as rate_code,
    count(distinct stored_flag) as stored_flag,
    count(distinct extra_charges) as extra_charges,
    count(distinct improvement_charge) as improvement_charge,
    count(distinct total_amount) as total_amount
from cabs;

select distinct extra_charges from cabs;

select extra_charges,round(100*(count(*)/(select count(*) from cabs)),5) as percentage
from cabs
group by extra_charges;

-- Dropping unnecessay column
alter table cabs
drop column mta_tax,
drop column improvement_charge;

alter table cabs
drop column id;

select * from cabs;


describe cabs;

select 
vendor_id,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as percentage
from cabs
group by vendor_id;

select 
passenger_nums,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by passenger_nums
order by `total_count` desc;

select 
payment_method,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by payment_method
order by `total_count` desc;

select 
rate_code,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by rate_code
order by `total_count` desc;

select 
stored_flag,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by stored_flag
order by `total_count` desc;
# Unncessary column with partial to one value, remove it

alter table cabs
drop column stored_flag;

select 
extra_charges,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by extra_charges
order by `total_count` desc;
# Extra charges have some values which can be classified as text, so we convert this column to text

update cabs
set extra_charges = 2
where extra_charges > 1;

alter table cabs
modify column extra_charges varchar(20);

update cabs
set extra_charges = '1+'
where extra_charges = '2';

select 
extra_charges,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by extra_charges
order by `total_count` desc;

update cabs
set extra_charges = 0
where extra_charges = '0.8' or
extra_charges = '0.05' or
extra_charges = '0.2' or
extra_charges = '0.1' ;

select 
extra_charges,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by extra_charges
order by `total_count` desc;

select
pickup_loc,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by pickup_loc
order by `total_count` desc
limit 10;

select
drop_loc,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by drop_loc
order by `total_count` desc
limit 10;

with duplicate as(
    select 'driver_tip' as col, driver_tip as val from cabs
    union all
    select 'distance',distance from cabs
    union all
    select 'toll_amount',toll_amount from cabs
    union all
    select 'total_amount',total_amount from cabs
) select 
col,
max(val) as max_val, 
min(val) as min_val, 
round(avg(val),2) as average_val
from duplicate
group by col;

alter table cabs
add column ride_duration double;

update cabs
set ride_duration = 
    timestampdiff(minute, pick_time,drop_time);

alter table cabs
add column p_time varchar(50),
add column d_time varchar(50);

select * from cabs;

update cabs
set p_time = 
    case
    when hour(pick_time) between 5 and 8 then 'morning'
    when hour(pick_time) between 9 and 12 then 'late_morning'
    when hour(pick_time) between 13 and 16 then 'afternoon'
    when hour(pick_time) between 17 and 20 then 'evening'
    when hour(pick_time) between 21 and 23 then 'night'
    when hour(pick_time) between 0 and 4 then 'midnight'
end;

update cabs
set d_time = 
    case
    when hour(drop_time) between 5 and 8 then 'morning'
    when hour(drop_time) between 9 and 12 then 'late_morning'
    when hour(drop_time) between 13 and 16 then 'afternoon'
    when hour(drop_time) between 17 and 20 then 'evening'
    when hour(drop_time) between 21 and 23 then 'night'
    when hour(drop_time) between 0 and 4 then 'midnight'
end;

select * from cabs;

update cabs
set pick_time = date(pick_time);    

alter table cabs
modify pick_time date;

update cabs
set drop_time = date(drop_time);

alter table cabs
modify drop_time date;

with duplicate as(
    select 'pick_time' as time, pick_time as val from cabs
    union all
    select 'drop_time',drop_time from cabs
)
select time, min(val) as minimum,max(val) as maximum
from duplicate
group by time;

describe cabs;

alter table cabs
rename column pick_time to pickup_date,
rename column drop_time to drop_date,
rename column p_time to pickup_time,
rename column d_time to drop_time;

select min(ride_duration) as minimum, 
max(ride_duration) as maximum,
round(avg(ride_duration),2) as average
from cabs;

select 
pickup_time,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by pickup_time
order by `total_count` desc;

select 
drop_time,
count(*) as total_count, 
concat(round(100*count(*)/(select count(*) from cabs),2),"%") as `percentage`
from cabs
group by drop_time
order by `total_count` desc;


-- ==========================================
-- Bivariate analysis of the data
-- ==========================================

select 
vendor_id,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount
from cabs
group by vendor_id
order by vendor_id;

select 
passenger_nums,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by passenger_nums
order by passenger_nums;

select 
payment_method,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by payment_method
order by payment_method;

select 
rate_code,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by rate_code
order by rate_code;

select 
pickup_time,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by pickup_time
order by pickup_time;

select 
drop_time,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by drop_time
order by drop_time;

select 
dayname(pickup_date) as day_name,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by dayname(pickup_date)
order by dayname(pickup_date);

select 
dayname(drop_date) as day_name,
min(total_amount) as min_amount,
max(total_amount) as max_amount,
round(sum(total_amount),2) as total_amount,
round(avg(total_amount),2) as average_amount,
count(total_amount) as `count`
from cabs
group by dayname(drop_date)
order by dayname(drop_date);

alter table cabs
drop column pickup_loc,
drop column drop_loc;

select * from cabs;

select
    sum(case when toll_amount = 0 then 1 else 0 end) as no_toll,
    sum(case when toll_amount != 0 then 1 else 0 end) as toll
from cabs; 

select * from cabs;

with duplicate as
(select *, 
row_number() over(partition by vendor_id,driver_tip,distance,pickup_date,drop_date,passenger_nums,toll_amount,
                                payment_method,rate_code,extra_charges,total_amount,ride_duration,pickup_time,drop_time) as rn
from cabs)
select * from duplicate
where rn > 1;
