-- Active: 1745477253100@@127.0.0.1@3306@heart
select * from data;

create table data_backup 
as 
select * from data;

select * from data_backup;

select * from data;

alter table data
rename column dataset to origin,
rename column cp to chest_pain,
rename column trestbps to blood_pressure,
rename column fbs to blood_sugar,
rename column restecg to resting_ecg,
rename column thalch to max_heart_rate,
rename column exang to ex_angina,
rename column oldpeak to st_depression,
rename column ca to major_vessel,
rename column num to category;

select * from data;

select count(*) as row_count,
   ( select count(*) from information_schema.columns
        where table_schema = database() and
        table_name = 'data') as column_count
from data;

describe data;

select * from data;


with duplicate as
(select *, row_number() 
over(partition by `age`,sex,origin,chest_pain,blood_pressure,chol,blood_sugar,resting_ecg,
                            max_heart_rate,ex_angina,st_depression,`slope`,major_vessel,thal,category) 
                            as row_num
from data)
select * from duplicate
where row_num >1;

delete from data
where id = 406 and id = 860;

select * from data;

select 
count( distinct `id` ) as `id`,
count( distinct age ) as age,
count( distinct sex ) as sex,
count( distinct origin ) as origin,
count( distinct chest_pain ) as chest_pain,
count( distinct blood_pressure ) as blood_pressure,
count( distinct chol ) as chol,
count( distinct blood_sugar ) as blood_sugar,
count( distinct resting_ecg ) as resting_ecg,
count( distinct max_heart_rate ) as max_heart_rate,
count( distinct ex_angina ) as ex_angina,
count( distinct st_depression ) as st_depression,
count( distinct slope ) as slope,
count( distinct major_vessel ) as major_vessel,
count( distinct thal ) as thal,
count( distinct category ) as category
from data;

alter table data
modify column blood_sugar varchar(10),
modify column ex_angina varchar(10),
modify column major_vessel varchar(10),
modify column category varchar(10);

select * from data;

describe data;

select 
sum(`id` is null) as `id`,
sum(age is null) as age,
sum(sex is null) as sex,
sum(origin is null) as origin,
sum(chest_pain is null) as chest_pain,
sum(blood_pressure is null) as blood_pressure,
sum(chol is null) as chol,
sum(blood_sugar is null) as blood_sugar,
sum(resting_ecg is null) as resting_ecg,
sum(max_heart_rate is null) as max_heart_rate,
sum(ex_angina is null) as ex_angina,
sum(st_depression is null) as st_depression,
sum(slope is null) as slope,
sum(major_vessel is null) as major_vessel,
sum(thal is null) as thal,
sum(category is null) as category
from data;

select * from data
where blood_pressure is null and
chol is null and
blood_sugar is null
and resting_ecg is null
and max_heart_rate is null
and ex_angina is null
and st_depression is null
and slope is null and
major_vessel is null and
thal is null;


--- ======================================
--- Univariate Analysis and data cleaning
--- ======================================

--- Numerical Columns
with duplicate as
(select age,
row_number() over(order by age asc) as rn,
count(*) over() as total
from data
)
select min(age) as minimum, 
max(age) as maximum, 
round(avg(age),2) as average,
(
    select age 
    from duplicate
    where rn = floor(.25 * total)) as 25th_percentile,
(
    select age 
    from duplicate
    where rn = floor(.50 * total)) as 50th_percentile,
(
    select age 
    from duplicate
    where rn = floor(.75 * total)) as 75th_percentile
from duplicate;

with duplicate as
(select blood_pressure,
row_number() over(order by blood_pressure asc) as rn,
count(*) over() as total
from data
)
select min(blood_pressure) as minimum, 
max(blood_pressure) as maximum, 
round(avg(blood_pressure),2) as average_blood_pressure,
(
    select blood_pressure 
    from duplicate
    where rn = floor(.25 * total)) as 25th_percentile,
(
    select blood_pressure 
    from duplicate
    where rn = floor(.50 * total)) as 50th_percentile,
(
    select blood_pressure 
    from duplicate
    where rn = floor(.75 * total)) as 75th_percentile
from duplicate;

select * from data
where blood_pressure < 50;

update data
set blood_pressure = null
where id = 754;

with duplicate as
(select chol,
row_number() over(order by chol asc) as rn,
count(*) over() as total
from data
)
select min(chol) as minimum, 
max(chol) as maximum, 
round(avg(chol),2) as average_chol,
(
    select chol 
    from duplicate
    where rn = floor(.25 * total)) as 25th_percentile,
(
    select chol 
    from duplicate
    where rn = floor(.50 * total)) as 50th_percentile,
(
    select chol 
    from duplicate
    where rn = floor(.75 * total)) as 75th_percentile
from duplicate;

select * from data
where chol=0;

update data
set chol = null
where chol = 0;

with duplicate as
(select max_heart_rate,
row_number() over(order by max_heart_rate asc) as rn,
count(*) over() as total
from data
)
select min(max_heart_rate) as minimum, 
max(max_heart_rate) as maximum, 
round(avg(max_heart_rate),2) as average_max_heart_rate,
(
    select max_heart_rate 
    from duplicate
    where rn = floor(.25 * total)) as 25th_percentile,
(
    select max_heart_rate 
    from duplicate
    where rn = floor(.50 * total)) as 50th_percentile,
(
    select max_heart_rate 
    from duplicate
    where rn = floor(.75 * total)) as 75th_percentile
from duplicate;

with duplicate as
(select st_depression,
row_number() over(order by st_depression asc) as rn,
count(*) over() as total
from data
)
select min(st_depression) as minimum, 
max(st_depression) as maximum, 
round(avg(st_depression),2) as average_st_depression,
(
    select st_depression 
    from duplicate
    where rn = floor(.25 * total)) as 25th_percentile,
(
    select st_depression 
    from duplicate
    where rn = floor(.50 * total)) as 50th_percentile,
(
    select st_depression 
    from duplicate
    where rn = floor(.75 * total)) as 75th_percentile
from duplicate;

select * from data
where st_depression < 0;

--- Cateogical columns

select sex, concat(round(100*(count(sex)/(select count(*) from data)),2),"%") as `percentage`
from data
group by sex
order by percentage desc;

select origin, concat(round(100*(count(origin)/(select count(*) from data)),2),"%") as `percentage`
from data
group by origin
order by percentage desc;

select chest_pain, concat(round(100*(count(chest_pain)/(select count(*) from data)),2),"%") as `percentage`
from data
group by chest_pain
order by percentage desc;

select blood_sugar, concat(round(100*(count(blood_sugar)/(select count(*) from data)),2),"%") as `percentage`
from data
group by blood_sugar
order by percentage desc;

select resting_ecg, concat(round(100*(count(resting_ecg)/(select count(*) from data)),2),"%") as `percentage`
from data
group by resting_ecg
order by percentage desc;

select ex_angina, concat(round(100*(count(ex_angina)/(select count(*) from data)),2),"%") as `percentage`
from data
group by ex_angina
order by percentage desc;

select slope, concat(round(100*(count(slope)/(select count(*) from data)),2),"%") as `percentage`
from data
group by slope
order by percentage desc;

select major_vessel, concat(round(100*(count(major_vessel)/(select count(*) from data)),2),"%") as `percentage`
from data
group by major_vessel
order by percentage desc;

select thal, concat(round(100*(count(thal)/(select count(*) from data)),2),"%") as `percentage`
from data
group by thal
order by percentage desc;

select category, concat(round(100*(count(category)/(select count(*) from data)),2),"%") as `percentage`
from data
group by category
order by percentage desc;

--- ======================================
--- Bivariate Analysis
--- ======================================

--- Categorical vs Categorical

with duplicate as
(select sex,category,count(*) over(partition by sex) as gender_count from data)
select sex,category,concat(round(100*(count(*)/max(gender_count)),2),"%") as percentage_based_on_sex from duplicate
group by sex,category
order by sex,category;