create database sql_basic
--A1
select count(*) as 'total number of rows' from Customer
select count(*)as 'total number of rows' from prod_cat_info
select count(*)as 'total number of rows' from Transactions

--A2
select count(transaction_id) as 'total number of transaction'  from Transactions
where cast(total_amt as float)<0

--A3--It has already modified based on the question
select customer_Id,convert(date,DOB,105) as DOB,Gender,city_code from Customer
select transaction_id,cust_id,convert(date,tran_date,105) as tran_date,prod_subcat_code,prod_cat_code,Qty,Rate,Tax,total_amt,Store_type from Transactions

--A4
with A1 as (select Top 1 '1' as TR,Convert(Date,tran_date,105) as date1 from Transactions order by date1 desc)  ,
A2 as (select Top 1 '1' as TR ,Convert(Date,tran_date,105) as date2 from Transactions order by date2 asc)
select datepart(day,A1.date1 )-datepart(day,A2.date2 ) as 'days',datepart(month,A1.date1 )-datepart(month,A2.date2 ) as 'month',datediff(year,A2.date2,A1.date1) as 'year'
from A1 left join A2 on A1.TR=A2.TR 

--A5
select prod_cat from prod_cat_info
where prod_subcat in ('DIY')


------DATA ANALYSIS-----

--A1
select channel from (select top 1 Store_type as channel,count(transaction_id) as 'total transaction' from Transactions
group by Store_type
order by 'total transaction' desc )as TR

--A2
select Gender,count(customer_Id) 'Total' from Customer
where Gender like '%M%' group by Gender
UNION ALL
select Gender,count(customer_Id) 'Total' from Customer
where Gender like '%F%' group by Gender

--A3
select top 1 city_code,count(customer_Id) 'No_customer' from Customer
group by city_code
order by 'No_customer' desc

--A4
select top 1 prod_cat,count(prod_subcat) 'Sub_categories' from prod_cat_info
where prod_cat='books'
group by prod_cat
order by prod_cat desc

--A5
select top 1 Qty 'max_quantity',cust_id from Transactions
order by cast(Qty as int)desc

--A6
select round(sum(cast(total_amt as float)),2)'total revenue' from Transactions as t left join prod_cat_info as p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in ('Electronics','Books')

--A7
select cust_id,count(cust_id)'customers' from Transactions
where cast(total_amt as float) >0
group by cust_id
having count(transaction_id)>10

--A8
select round(sum(cast(total_amt as float)),2)'combined revenue' from Transactions as t left join prod_cat_info as t2 on t.prod_cat_code=t2.prod_cat_code and t.prod_subcat_code=t2.prod_sub_cat_code
where prod_cat in ('Electronics','Clothing') and Store_type like ('Flagship%')

--A9
select prod_subcat,round(sum(cast(total_amt as float)),2) 'total revenue' from Transactions as t  left join prod_cat_info as p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code left join Customer as c on t.cust_id=c.customer_Id
where Gender like 'M%' and prod_cat like 'Electronics'
group by prod_subcat

--A10
select sub_categories,round(sum(sales)/(select sum(cast(total_amt as float)) from Transactions)*100,2) 'sales in Percentage', abs(round(sum([return])/(select sum(cast(total_amt as float)) from Transactions)*100,2)) 'returns in Percentage'
from (select prod_subcat as sub_categories,cast(total_amt as float)as Sales,
case when cast(total_amt as float)<0 then (cast(total_amt as float)) else 0 end as [return]
from Transactions as t left join prod_cat_info as t2 on t.prod_cat_code=t2.prod_cat_code and t.prod_subcat_code=t2.prod_sub_cat_code
where prod_subcat in (select top 5 prod_subcat  from Transactions as t left join prod_cat_info as t2 on t.prod_cat_code=t2.prod_cat_code and t.prod_subcat_code=t2.prod_sub_cat_code
group by  prod_subcat
order by sum(cast(total_amt as float)) desc)) as t 
group by sub_categories

--A11
select round(sum(cast(total_amt as float)),2) 'total revenue' from Transactions as t left join Customer as c on t.cust_id=c.customer_Id
where datediff(YEAR,convert(date,DOB,105),(select max(convert(date,tran_date,105)) from Transactions)) between 25 and 35 and
datediff(day,(select max(convert(date,tran_date,105)) from Transactions),dateadd(DAY,-30,(select max(convert(date,tran_date,105)) from Transactions)))=-30

--A12
select prod_cat from prod_cat_info as p left join Transactions as t on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
where cast(total_amt as float)<0 and datediff(month,(select max(convert(date,tran_date,105)) from Transactions),dateadd(month,-3,(select max(convert(date,tran_date,105)) from Transactions)))=-3
group by prod_cat
order by count(transaction_id) desc

--A13
select Store_type 'store sales maxm' from (select top 1 Store_type, sum(cast(total_amt as float))'sales_amount',sum(cast(total_amt as float))'quantity_sold' from Transactions
group by Store_type
order by sales_amount desc,quantity_sold desc) as e

--A14
select prod_cat from(select prod_cat,  avg(cast(total_amt as float)) 'total_avg' from prod_cat_info as pr left join Transactions as tr on pr.prod_cat_code=tr.prod_cat_code and pr.prod_sub_cat_code=tr.prod_subcat_code
group by prod_cat
having avg(cast(total_amt as float)) > (select avg(cast(total_amt as float)) from Transactions)) as e1

--A15
with w1 as ( select top 5 prod_cat_code,sum(cast(Qty as int)) 'total_quantity' from Transactions
group by prod_cat_code 
order by total_quantity desc),
w2 as( select top 5 prod_cat,t.prod_cat_code,prod_subcat ,round(avg(cast(total_amt as float)),2)'total_avg',round(sum(cast(total_amt as float)),2)'total_revenue' from prod_cat_info as p left join Transactions as t on p.prod_cat_code=t.prod_cat_code and p.prod_sub_cat_code=t.prod_subcat_code
group by t.prod_cat_code,prod_cat,prod_subcat) 
select *from w1 left join w2 on w1.prod_cat_code=w2.prod_cat_code where total_revenue is not null
