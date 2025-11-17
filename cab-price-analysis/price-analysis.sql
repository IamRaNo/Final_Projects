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


select count(distinct vendor_id) as vendor_id,
    count(distinct pickup_loc) as pickup_loc,
    count(distinct drop_loc) as drop_loc,
    count(distinct mta_tax) as mta_tax,
    count(distinct toll_amount) as toll_amount,
    count(distinct payment_method) as payment_method,
    count(distinct rate_code) as rate_code,
    count(distinct extra_charges) as extra_charges
from cabs;


select * from cabs;


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


delete from cabs
    where
    pickup_loc is null;


select * from cabs;


select distinct vendor_id from cabs;

select distinct mta_tax from cabs;

update cabs
set mta_tax = 0
    where mta_tax is null;


select min(distance) as minimum, max(distance) as maximum from cabs;


select min(passenger_nums) as minimum, max(passenger_nums) as maximum from cabs;


select min(toll_amount) as minimum, max(toll_amount) as maximum from cabs;



select distinct payment_method from cabs;


select distinct rate_code from cabs;

select distinct stored_flag from cabs;


select min(extra_charges) as charge,min(improvement_charge) as improve , min(total_amount) as amount from cabs;


select * from cabs;

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



-- ==========================================
-- Modifying the data
-- ==========================================




-- ==========================================
-- Univariate analysis of the data
-- ==========================================

-- ==========================================
-- Bivariate analysis of the data
-- ==========================================

-- ==========================================
-- Multivariate analysis of the data
-- ==========================================