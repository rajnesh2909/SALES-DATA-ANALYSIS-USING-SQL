--top 10 highest revenue generating products

select product_id, sum(sale_price)*sum(quantity) as tot_sales
from df_orders
group by product_id
order by sum(sale_price) desc
limit 10
					   
					   
--top 5 products in each region

with cte as(
	select product_id, region, sum(sale_price)*sum(quantity) as tot_sales ,
	row_number() over
	(partition by region
	order by (sum(sale_price)*sum(quantity)) desc) as row
	from df_orders
	group by product_id , region
	order by region , tot_sales desc)
select product_id ,region , tot_sales
from cte 
where row<=5

select * from df_orders

--month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023


with cte as(
select extract(Year from order_date) as order_year ,
	   extract(month from order_date) as order_month , sum(sale_price)
from df_orders
group by order_year , order_month
order by order_month)

select a.order_month , b.sum as sales_2022 , a.sum as sales_2023
from cte as a
cross join cte as b
where a.order_year-b.order_year=1 and a.order_month=b.order_month




--month which had highest sales for each category


with cte as

(select extract(Year from order_date) as order_year,
	   extract(month from order_date) as order_month ,
	   category,  sum(sale_price)
from df_orders
group by order_year , order_month , category
order by order_month ,category)

select category,order_year,order_month,sum as sales 
from 
(select * ,
row_number() over (partition by category order by sum desc) as rn
from cte) as temp
where rn=1




--subcategory with highest growth by profit in 2023 compare to 2022



with cte as(

select sub_category,extract(Year from order_date) as order_year,sum(sale_price)
from df_orders as a
group by order_year,sub_category
order by sub_category)

select cat as sub_category , (sales_23-sales_22) as sales_growth_by_year
from 
(select a.sub_category as cat,a.sum as sales_23,b.sum as sales_22
from cte as a
cross join cte as b
where a.sub_category=b.sub_category and a.order_year-b.order_year=1)
order by sales_growth_by_year desc
limit 1

