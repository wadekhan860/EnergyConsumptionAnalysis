
Select Organization, count(*) from Task2_raw
group by Organization

Select count(*) from Task2_raw
where len (Organization) < 1

--Deleting all rows where Organization is empty
Delete from Task2_raw
where len(Organization) < 1

Select count(*) from Task2

--Deleting rows where Organization is LCH
Select count(*) from Task2_raw
where Organization = 'Lake City Housing'


Delete from Task2_raw
where Organization = 'Lake City Housing'


-- Dropping Column cs from table
Alter table Task2_raw drop column cs

Select top 1000 * from Task2_raw
order by Organization

--Created and executed 2 procedures to create 2 working tables from the raw table.
--These working tables have changed data types and are split into 2 tables


Select top 1000 * from [WRK_Task2_1]
order by date_time

Select top 100 * from [WRK_Task2_2]



--Adding MF Column 
Alter table [WRK_Task2_2] add MF int

UPDATE [dbo].[WRK_Task2_2]
SET [MF] = ct_ratio * pt_ratio

--Converting Data Types of date and time
UPDATE [dbo].[WRK_Task2_1]
SET [date] = CONVERT(DATE,[date])

--Combining columns of date and time
Alter table [WRK_Task2_1] add date_time varchar(100)
Alter table [WRK_Task2_1] drop column date_time



UPDATE [dbo].[WRK_Task2_1]
set [date_time] =  CONCAT([date],' ',[time])

UPDATE [dbo].[WRK_Task2_1]
SET [date_time] = CONVERT(datetime2,[date_time])

Select top 1000 * from [WRK_Task2_1]
order by date_time

SET time = RIGHT('0000' + time, 4)

SELECT top 100 RIGHT('0000' + time,4) AS time_new
FROM [WRK_Task2_1]
order by date, time_new



--Adding and Calculating Units Column 
Alter table [WRK_Task2_1] add Units float


SELECT top 200
rtu_id, mp_id, date_time, WRK_Task2_1.bd_zy , LAG(WRK_Task2_1.bd_zy) OVER (ORDER BY rtu_id, mp_id, date_time) Previous_Value, 
WRK_Task2_1.bd_zy - LAG(WRK_Task2_1.bd_zy,1) OVER (ORDER BY rtu_id, mp_id, date_time) Units
FROM WRK_Task2_1

Select rtu_id, mp_id, date, time from [WRK_Task2_1]
order by  time

--Finding Units using CTE

WITH cte_units AS (
	SELECT 
		rtu_id, 
		mp_id,
		date_time,
		bd_zy,
		LAG(bd_zy,1) OVER (ORDER BY rtu_id,mp_id, date_time) previous_units
	FROM WRK_Task2_1
)

SELECT 
	rtu_id,
	mp_id,
	date_time,
	bd_zy, 
	previous_units,
	(bd_zy - previous_units) Units
into Units
FROM
	cte_units

drop table Units
Select * from Units
order by rtu_id, mp_id, date_time

--date_time column is included to Units column
alter table Units add date_time datetime2
update Units
set date_time = CONCAT(Task2_dates.date_time,' ') from Task2_dates


--Trying to convert date_time column from varchar to datetime type
SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS

update Units
set date_time = parse(date_time as datetime2 USING 'it-IT')

update Units
set date_time = cast(date_time as datetime2)

update Units
set date_time = try_convert(datetime2, date_time,121)


update Units
set date_time = CONCAT(substring(WRK_Task2_1.date_time,1,10),' ',
substring(WRK_Task2_1.date_time,12,2),':',substring(WRK_Task2_1.date_time,14,2)) from [WRK_Task2_1]

update [WRK_Task2_1]
set date_time = CONCAT(substring(WRK_Task2_1.date_time,1,10),' ',
substring(WRK_Task2_1.date_time,12,2),':',substring(WRK_Task2_1.date_time,14,2)) from [WRK_Task2_1]

Select top 50 substring(date_time,1,10),substring(date_time,12,2),substring(date_time,14,2) from [WRK_Task2_1]
order by rtu_id,mp_id


--V modelling. Finding outages and their duration and then avg units 

Select * from Units
where Units = 0
order by rtu_id, mp_id

alter table [dbo].[Task2_dates] add outage_duration varchar(20)

--Doesnt work because dates can not be subtracted in datetime2 format
--Select top 2 *, date_time - LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time) from [dbo].[Task2_dates]

--select top 5 *,LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time) previous_time,
--datediff(minute,LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),date_time) as diff
--from [dbo].[Task2_dates] 
--order by rtu_id, mp_id,date_time

--Select top 100 * from Task2_dates1
--ORDER BY rtu_id,mp_id, date_time


--alter table Task2_dates1 add kWh float
--alter table Task2_dates1 drop column Units float

--create table Task2_dates1(rtu_id varchar(50),mp_id varchar(50),date_time datetime2,previous_time datetime2,diff varchar(10))
--INSERT INTO Task2_dates1 (rtu_id,mp_id,date_time,previous_time,diff)
--SELECT rtu_id,mp_id,date_time, LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),
--datediff(minute,LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),date_time) 
--from [dbo].[Task2_dates] 
--order by rtu_id, mp_id,date_time


--create table Units1(rtu_id varchar(50),mp_id varchar(50),date_time datetime2,previous_time datetime2,diff varchar(10),
--bd_zy float,previous_units float, Units float)

--INSERT INTO Units1 (rtu_id,mp_id,date_time,previous_time,diff,bd_zy,previous_units,Units)
--SELECT rtu_id,mp_id,date_time, LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),
--datediff(minute,LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),date_time),bd_zy,previous_units,Units
--from [dbo].[Units] 
--order by rtu_id, mp_id,date_time

--Select top 10 * from Task2_dates1
--order by rtu_id,mp_id,date_time

--drop table Units1

--Select rtu_id,mp_id,date_time,bd_zy from [dbo].[WRK_Task2_1]
--drop table [dbo].[Task2_dates1],[dbo].[Units]
--Select top 10 * from Units
--Select top 10 * from [dbo].[Task2_dates1]

Select top 10 * from [dbo].[Task2_new]

create table Units1(rtu_id varchar(50),mp_id varchar(50),prev_rtu_id varchar(50),prev_mp_id varchar(50),
date_time datetime2,previous_time datetime2,diff varchar(10),
bd_zy float,previous_units float, Units float)

truncate table  Units1
INSERT INTO Units1 (rtu_id,mp_id,prev_rtu_id,prev_mp_id,date_time,previous_time,diff,bd_zy,previous_units,Units)

SELECT rtu_id,mp_id,LAG(rtu_id) OVER (ORDER BY  rtu_id,mp_id) ,
LAG(mp_id) OVER (ORDER BY  rtu_id,mp_id) 
,date_time, LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),
datediff(minute,LAG(date_time,1) OVER (ORDER BY rtu_id,mp_id, date_time),date_time) ,bd_zy,
case when rtu_id = LAG(rtu_id) OVER (ORDER BY  rtu_id,mp_id) and mp_id =  LAG(mp_id) OVER (ORDER BY  rtu_id,mp_id)
then LAG(Task2_new.bd_zy) OVER (ORDER BY rtu_id, mp_id, date_time)
else Null
end,
case when rtu_id = LAG(rtu_id) OVER (ORDER BY  rtu_id,mp_id) and mp_id =  LAG(mp_id) OVER (ORDER BY  rtu_id,mp_id)
then (bd_zy - LAG(bd_zy,1) OVER (ORDER BY rtu_id, mp_id, date_time))
else Null
end
from Task2_new
order by rtu_id, mp_id,date_time

Select * from Units1
--Select  count(Units) from Units1
--where Units < -1


Select *, IIF(Units=0, 'True','False') from Units1

Select *, IIF(Units=0, ,'False') from Units1
--Creating Avgs Table
create table Avgs(rtu_id varchar(50),mp_id varchar(50), avg_units float)
insert into Avgs(rtu_id,mp_id,avg_units)

Select rtu_id,mp_id, avg(units) 
from Units1
group by rtu_id,mp_id
order by mp_id,rtu_id

Select * from Avgs


--Update value of rtu_id = 30000933 and mp_id = 3 with avg of august
Select * from Units1
where rtu_id = 30000933 and mp_id = 3 and Units >100

Select * from Units1
where rtu_id = 30000933 and mp_id = 3 and Units <-100
order by date_time


Select * from Units1

--Select * from [dbo].[Task2_raw]
--where rtu_id = 30000933 and mp_id = 3 and bd_zy <-100
--order by date , time

Select avg(units) from Units1
where rtu_id = 30000933 and mp_id = 3 and Units > -1 and date_time like '%2021-08-__%'


declare @avg_units_aug float
select @avg_units_aug = avg(units) from Units1
where rtu_id = 30000933 and mp_id = 3 and Units > -1 and date_time like '%2021-08-__%'

Update Units1
set Units = @avg_units_aug from Units1
where rtu_id = 30000933 and mp_id = 3  and Units < -1 and date_time like '%2021-08-25%'

--Modelling
--declare @avgunits float 
--SELECT  @avgunits = avg(units)  FROM Units1 where rtu_id = prev_rtu_id and mp_id = prev_mp_id

--alter table Units1 add avgs float
--update Units1
--set avgs = avg_units from Avgs
--where Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id

Select * from Units1
Select * from avgs




--select Units1.rtu_id,Units1.mp_id,date_time,Units,
--				case when Units = 0 and Units is not null 
--                   then (select avg_units from Avgs
--							inner join Units1 on Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id
--							where Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id 
--							)
--                   else Units1.Units
--              end 
--from Avgs
--inner join Units1 on Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id
--where Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id

--select Units1.rtu_id,Units1.mp_id, Units,Avgs.rtu_id,Avgs.mp_id, avg_units from Avgs
--							inner join Units1 on Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id
--							where Avgs.rtu_id = Units1.rtu_id and Avgs.mp_id=Units1.mp_id


--temporary solution for avgs
select rtu_id,mp_id,date_time,Units,
				case when Units = 0 and Units is not null 
                   then Units1.avgs
                   else Units1.Units
              end 
from Units1

Select * from avgs
order by rtu_id,mp_id


--Finding outages
create table Units2(rtu_id varchar(50),mp_id varchar(50),prev_rtu_id varchar(50),prev_mp_id varchar(50),
date_time datetime2,previous_time datetime2,diff varchar(10),
bd_zy float,previous_bd_zy float, Units float, previous_units float)

truncate table Units2

INSERT INTO Units2 (rtu_id,mp_id,prev_rtu_id,prev_mp_id,date_time,previous_time,diff,bd_zy,previous_bd_zy,Units,previous_units)

Select rtu_id,mp_id,prev_rtu_id,prev_mp_id,date_time,previous_time,diff, bd_zy,previous_bd_zy, Units,
case when rtu_id = LAG(rtu_id) OVER (ORDER BY  rtu_id,mp_id) and mp_id =  LAG(mp_id) OVER (ORDER BY  rtu_id,mp_id)
then LAG(Units) OVER (ORDER BY rtu_id, mp_id)
else Null
end
from Units1

--Creating an outage table

create table Units3(rtu_id varchar(50),mp_id varchar(50),
date_time datetime2,previous_time datetime2,diff varchar(10), outage varchar(20))

truncate table Units3

insert into Units3(rtu_id,mp_id,date_time,previous_time,diff,outage)


Select rtu_id,mp_id,date_time,previous_time,diff,
case when diff != 15 and units!=previous_units  then 'Connectivity Issue' 
when diff != 15 and units = previous_units then 'Outage'
else 'Normal' 
end 
from Units2
where Units != 0 and previous_units != 0
order by rtu_id, mp_id, date_time

Select * from Units2
Select * from Units1
--Finding start-end time of outages

Select * from Units3 
where outage != 'Normal'

create table outages_time (rtu_id varchar(50), mp_id varchar(50), outage varchar(50), start_time datetime2, end_time datetime2)

truncate table outages_time

insert into outages_time(rtu_id,mp_id,outage,start_time,end_time)

Select rtu_id,mp_id, outage, date_time, case when Lead(outage) OVER (ORDER BY  rtu_id,mp_id,date_time) != outage 
then lead (date_time) over (order by rtu_id, mp_id) end end_time
from Units3
where outage != 'Normal' 

Select * from outages_time

create table outages_time1 (rtu_id varchar(50), mp_id varchar(50), outage varchar(50), start_time datetime2, end_time datetime2)

truncate table outages_time1

insert into  outages_time1 (rtu_id,mp_id,outage,start_time,end_time)

Select * from outages_time
where end_time is not null


Select * from outages_time1



Select * from units_all
Select * from outage_status
Select * from outage_times
Select * from Avgs

Select * from [dbo].[WRK_Task2_2]


--Filtering Tables for few months of data

Select  * from [dbo].[outage_status]
where date_time like '2021-11-%'
order by date_time

Select  * from [dbo].[outage_times]
where start_time like '2021-11-%' 
order by start_time

Select  rtu_id,mp_id,date_time,Units from [dbo].[units_all]
where date_time like '2021-11-%'
order by date_time



Select top 100 rtu_id,mp_id,describe,Organization,Province,City,Category,Department,[Group],[Name] from [dbo].[Task2_raw]
where [date] like'202111%' 
,




