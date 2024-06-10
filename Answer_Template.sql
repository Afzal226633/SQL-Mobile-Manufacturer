--SQL Advance Case Study


--Q1--BEGIN 
select b.state from fact_transactions a
	left join dim_location b on a.idlocation = b.idlocation
	left join dim_customer c on a.idcustomer = c.idcustomer
	where year(date) >= '2005'
	group by b.state

--Q1--END

--Q2--BEGIN
select   top 1 d.state from DIM_MANUFACTURER a
	inner join DIM_MODEL b  on a.IDManufacturer = b.IDManufacturer
	left join FACT_TRANSACTIONS c  on b.IDModel = c.IDMOdel
	left join dim_location d  on c.idlocation = d.idlocation
	where a.Manufacturer_Name = 'samsung' and Country= 'US'
	group by d.state 
	order by count(Quantity) desc


--Q2--END

--Q3--BEGIN      
	
select Model_Name, ZipCode,state, count(IDCustomer) as No_of_transaction
	from (
		select t.*,l.State,l.ZipCode ,m.Model_Name from  FACT_TRANSACTIONS t
		left join DIM_MODEL m
		on t.IDModel = m.IDModel
		left join DIM_LOCATION l
		on t.IDLocation = l.IDLocation
		--group by  t.IDCustomer,t.TotalPrice,t.IDLocation,t.IDModel,t.[Date],l.State,l.ZipCode 
		) as x
	group by Model_Name,state,ZipCode


--Q3--END

--Q4--BEGIN
select top 1  Model_Name,Unit_price ,Manufacturer_Name from DIM_MODEL d
	left join DIM_MANUFACTURER m
	on d.IDManufacturer = m.IDManufacturer
	order by Unit_price

--Q4--END

--Q5--BEGIN

WITH saurabh 
AS ( 
		select top 5 Manufacturer_Name,Model_Name,avg_price ,Quantity
		from (
				select count(f.Quantity) as Quantity ,m.Manufacturer_Name,d.Model_Name,
				avg(f.totalprice) as avg_price   
				from FACT_TRANSACTIONS f
				inner join DIM_MODEL d
				on f.IDModel = d.IDModel
				inner join DIM_MANUFACTURER m
				on d.IDManufacturer = m.IDManufacturer
				group by m.Manufacturer_Name,d.Model_Name
				) 
		as y 
		group by Manufacturer_Name,Model_Name,avg_price,Quantity
		order by Quantity desc 
	)

select  Model_Name,avg_price  from saurabh 
	order by avg_Price desc


--Q5--END

--Q6--BEGIN
select * from (
				select Customer_Name,avg(totalprice) as avagare_amount from dim_customer c
				left join FACT_TRANSACTIONS f
				on c.IDCustomer = f.IDCustomer
				where year(date) =2009
				group by Customer_Name
				) as y 
	where avagare_amount >500
	order by avagare_amount

--Q6--END
	
--Q7--BEGIN  
	select Model_Name 
		from (
			select top 5  count(quantity) as quantity,
			Model_Name from DIM_MODEL m
			inner join FACT_TRANSACTIONS f
			on m.IDModel = f.IDModel
			where year(date) in (2008,2009,2010)
			group by Model_Name
			order by quantity desc
			) as S
	
--Q7--END	
--Q8--BEGIN

WITH top2_sales 
	as (
		select * ,DENSE_RANK() over(order by Sales desc) denserank
		from (
				select --count(d.IDManufacturer) as id_manu, 
				d.Manufacturer_Name,sum(f.TotalPrice) Sales from DIM_MODEL m
				inner join  DIM_MANUFACTURER d 
				on m.idmanufacturer = d.idmanufacturer 
				inner join FACT_TRANSACTIONS f
				on m.IDModel = f.IDModel
				where year(date) =2009
				group by  d.Manufacturer_Name
			) as Z
	union
		select * , dense_rank () over (order by Sales desc)  as denserank
		from(
				select --count(d.IDManufacturer) as id_manu, 
				d.Manufacturer_Name,sum(f.TotalPrice)  Sales --,DENSE_RANK() over(order by TotalPrice desc)  
				from DIM_MODEL m
				inner join  DIM_MANUFACTURER d 
				on m.idmanufacturer = d.idmanufacturer 
				inner join FACT_TRANSACTIONS f
				on m.IDModel = f.IDModel
				where year(date) =2010
				group by  d.Manufacturer_Name
			) as y
		) 
select Manufacturer_Name,Sales from top2_sales
where denserank = 2

--Q8--END
--Q9--BEGIN
	
select m.Manufacturer_Name from FACT_TRANSACTIONS f
 left join DIM_MODEL d 
 on f.IDModel = d.IDModel
 left join DIM_MANUFACTURER m
 on d.IDManufacturer = m.IDManufacturer
 where year (date) =2010
except
 select m.Manufacturer_Name from FACT_TRANSACTIONS f
 left join DIM_MODEL d 
 on f.IDModel = d.IDModel
 left join DIM_MANUFACTURER m
 on d.IDManufacturer = m.IDManufacturer
 where Year(date) = 2009


--Q9--END

--Q10--BEGIN
	
	select t1.IDCustomer, t1.Customer_Name,t1.avg_spend, t1.Avg_Qty,t1.year,
 --lag(t1.avg_spend,1) over (partition by t1.customer_name order by t1.year) as pre_year,
 Case when (t1.Year-t2.Year)=1 then (((t1.avg_spend-t2.avg_spend)/(t2.avg_spend) )* 100)
else null end AS 'yearly_%_change'
    FROM
        (SELECT p2.IDCustomer,p2.Customer_Name, YEAR(p1.DATE) AS year, AVG(p1.TotalPrice) AS avg_spend, AVG(p1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS p1 
			left join DIM_CUSTOMER as p2 ON p1.IDCustomer=p2.IDCustomer
			where p1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
			group by p2.IDCustomer,p2.Customer_Name, YEAR(p1.Date)
			--order by p2.IDCustomer
        )  as t1
    left join
        (SELECT p2.IDCustomer,p2.Customer_Name, YEAR(p1.DATE) AS year, AVG(p1.TotalPrice) AS avg_spend, AVG(p1.Quantity) AS Avg_Qty FROM FACT_TRANSACTIONS AS p1 
			left join DIM_CUSTOMER as p2 ON p1.IDCustomer=p2.IDCustomer
			where p1.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) desc)
			group by p2.IDCustomer,p2.Customer_Name, YEAR(p1.Date)
			--order by p2.IDCustomer
        ) as t2
     on t1.Customer_Name=t2.Customer_Name and t2.YEAR=t1.YEAR-1
	 order by t1.IDCustomer,t1.Customer_Name,year 

















--Q10--END
	