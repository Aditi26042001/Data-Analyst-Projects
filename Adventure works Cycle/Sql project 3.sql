create database	Adventure_works;
USE adventure_works;
SET SQL_SAFE_UPDATES = 0;
select * from fact_internet_sales_new;
select * from factinternetsales;
select * from combinedsalesdata;
/*----------------------------------------------------*/
/*0. Union of Fact Internet sales and Fact internet sales new*/

create table combinedsalesdata as
select * from (select * from factinternetsales union all select * from fact_internet_sales_new) as merged_data;

/*------------------------------------------------------------------------------------------------------------*/

/*1.Lookup the productname from the Product sheet to Sales sheet.*/

alter table combinedsalesdata 
add column EnglishProductName varchar(50);

update combinedsalesdata csd 
join dimproduct dp on csd.productkey = dp.productkey
set csd.EnglishProductName = dp.EnglishProductName;
/*------------------------------------------------------------------------------------------------------------*/
/*.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.*/

alter table dimcustomer
add column customer_full_name varchar (50) generated always as (trim(replace(concat_ws(' ',title,Firstname,middlename,lastname),'  ',' '))) stored;

alter table combinedsalesdata 
drop column month_no;

update combinedsalesdata csd
join dimcustomer dc on csd.customerkey = dc.customerkey
set csd.customer_full_name = dc.customer_full_name;
/*--------------------------------------------------------------------------------------------------------*/ 
3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey)
a) 
alter table combinedsalesdata
add column year int generated always as (year(orderdate));

alter table combinedsalesdata
add column year int;

update combinedsalesdata csd
set csd.year = year(orderdate);

b)
alter table combinedsalesdata
add column month_no int generated always as (month(orderdate));

alter table combinedsalesdata
add column month_no int;

update combinedsalesdata csd
set csd.month_no = month(orderdate);

c)
alter table combinedsalesdata
add column quarter varchar(2) generated always as (
case 
when month(orderdate) in(1, 2, 3) then 'Q1'
when month(orderdate) in(4, 5, 6) then 'Q2'
when month(orderdate) in(7, 8, 9) then 'Q3'
when month(orderdate) in(10, 11, 12) then 'Q4'
end);

alter table combinedsalesdata
add column quarter varchar(2);

update combinedsalesdata csd
set quarter = (
case 
when month(orderdate) in(1, 2, 3) then 'Q1'
when month(orderdate) in(4, 5, 6) then 'Q2'
when month(orderdate) in(7, 8, 9) then 'Q3'
when month(orderdate) in(10, 11, 12) then 'Q4'
end);

d)
alter table combinedsalesdata
add column year_monthname varchar(15) generated always as (date_format(orderdate, '%Y-%b'));

alter table combinedsalesdata
add column year_monthname varchar(15);

update combinedsalesdata csd
set csd.year_monthname = date_format(orderdate, '%Y-%b');

e)
alter table combinedsalesdata sunday =1 saturday =7
add column weekdayno int generated always as (dayofweek(orderdate));

alter table combinedsalesdata
add column weekdayno int;

update combinedsalesdata csd
set csd.weekdayno = dayofweek(orderdate);

f)
alter table combinedsalesdata 
add column month_name varchar(15) generated always as (monthname(orderdate));

alter table combinedsalesdata 
add column month_name varchar(15);

update COMBINEDSALESDATA csd
SET csd.month_name = monthname(orderdate);

g)
alter table combinedsalesdata
add column day_name varchar(15) generated always as (dayname(orderdate));

alter table combinedsalesdata
add column day_name varchar(15);

update combinedsalesdata csd
set csd.day_name = dayname(orderdate);

h)
alter table combinedsalesdata
add column financial_month int generated always as ( 
case
when month(orderdate)>=6 then month(orderdate) -5 else month(orderdate)+7
end);

alter table combinedsalesdata
add column financial_month int;

update combinedsalesdata csd
set csd.financial_month = ( 
case
when month(orderdate)>=6 then month(orderdate) -5 else month(orderdate)+7
end);

I)
alter table combinedsalesdata
add column financial_quarter varchar(2)

update combinedsalesdata csd
set  csd.financial_quarter = (
case 
when month(orderdate) in(6, 7, 8) then 'Q1'
when month(orderdate) in(9, 10, 11) then 'Q2'
when month(orderdate) in(12, 1, 2) then 'Q3'
when month(orderdate) in(3, 4, 5) then 'Q4'
end);
/*----------------------------------------------------------------------------------------*/
4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)

alter table combinedsalesdata
add column sales_amount decimal(10, 2); 

update combinedsalesdata csd
set csd.sales_amount = ((csd.unitPrice * csd.orderquantity) - csd.discountamount);
/*--------------------------------------------------------------------------------------*/
5.Calculate the Productioncost uning the columns(unit cost ,order quantity)

alter table combinedsalesdata 
add column totalproductioncost decimal(10,2);

update combinedsalesdata csd
set csd.totalproductioncost = (ProductStandardCost * orderQuantity);
/*--------------------------------------------------------------------------------------*/
6.Calculate the profit.

alter table combinedsalesdata 
add column profit decimal(10,2);

update combinedsalesdata csd
set csd.profit = (sales_amount - totalproductioncost);
/*------------------------------------------------------------------------------------*/
Q7. retrieve a data which show month and sales (provide the Year as filter to select a particular Year)

select Month_name, sum(sales_amount) as total_sales_amt 
from combinedsalesdata
where 
year = 2013
group by Month_name, month_no
order by Month_no;

/*----------------------------------------------------------------------------------------------*/
8.retrieve a data to show yearwise Sales

Select year, Sum(sales_amount)
from combinedsalesdata
group by year
order by year;
/*---------------------------------------------------------------------------------------------*/
9.retrieve a data to show Monthwise sales

select Month_name, sum(sales_amount) as total_sales_amt 
from combinedsalesdata
group by Month_name, month_no
order by Month_no;
/*--------------------------------------------------------------------------------------------*/
10.retrieve a data to show Quarterwise sales

select financial_quarter, sum(sales_amount) as total_sales_amt
from combinedsalesdata
group by financial_quarter
order by financial_quarter;
/*------------------------------------------------------------------------------------------*/
11.retrieve a data both Salesamount and Productioncost together to show year wise sales

select year, sum(sales_amount) as total_sales_amt, sum(totalproductioncost) as total_production_cost
from combinedsalesdata
group by year
order by year;
/*-----------------------------------------------------------------------------------------*/


