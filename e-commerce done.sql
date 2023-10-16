
------------------------------------------------------- Annual Customer Growth Analysis
with 
calc_mau as (
select 
		year,
		round(avg(mau),3) as avg_mau
from (
		select 
				date_part('year', o.order_purchase_timestamp) as year,
				date_part('month', o.order_purchase_timestamp) as month,
				count(distinct c.customer_unique_id) as mau
		from
				orders_data o
		join 
				customer_data c on o.customer_id=c.customer_id
		group by 
				1,2
) as subq
group by 1
),

calc_new_cust as (
select 
		date_part('year', first_purchase_time)	as year,
		count(1) as new_customer
from(
		select 
				c.customer_unique_id,
				min(o.order_purchase_timestamp) as first_purchase_time
		from 	
				customer_data c
		join
				orders_data o  on c.customer_id= o.customer_id
		group by 	
				1
) as subq2
	
group by 1
order by 1
),

calc_rep_cust as (
select 	
		year,
		count(distinct customer_unique_id) as repeat_customer
from (

		select 
				date_part('year', o.order_purchase_timestamp) as year,
				c.customer_unique_id,
				count(1) as purchase_frequency
		from
				orders_data o
		join
				customer_data c on o.customer_id = c.customer_id 
		group by 1,2
		having count(1) > 1
	
) subq3
group by 1
),

calc_avg_pur as (
select 
		year,
		round(avg(purchase_freq),3) as avg_purchase
from (
		select
				date_part('year', o.order_purchase_timestamp) as year,
				c.customer_unique_id,
				count(1) as purchase_freq
		from
				orders_data o
		join
				customer_data c on o.customer_id = c.customer_id 
		group by 
				1,2
				
) as subq4
group by 1
)



select 
		mau.year,
		mau.avg_mau,
		n.new_customer,
		r.repeat_customer,
		a.avg_purchase

from
		calc_mau mau
		
join
		calc_new_cust n on n.year = mau.year
join 
		calc_rep_cust r on r.year = mau.year
join 	
		calc_avg_pur a on a.year = mau.year
		
----------------------------------------------- Annual Product Category Quality Analysis
		
create table total_revenue_per_year as 

	select 
			date_part('year', o.order_purchase_timestamp) as year,
			sum(revenue_per_order)	as revenue
	from(
			select
					order_id,
					sum(price+freight_value) as revenue_per_order
					
			from
					order_items oi 
			group by 1
		) subq
	
	join 
			orders_data o on subq.order_id = o.order_id 
	where
			o.order_status = 'delivered'
	group by 1
	
	
		
create table total_cance_order as

	select 
			date_part('year', od.order_purchase_timestamp) as year,
			count(od.order_status) as order_canceled
	from
			orders_data od
			
	where 
			order_status = 'canceled'
	
	group by 1
	
		
create table top_product_category_by_revenue_per_year as 
select 
	year, 
	product_category_name, 
	revenue 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		sum(oi.price + oi.freight_value) as revenue,
		rank() over(partition by 
		date_part('year', o.order_purchase_timestamp) 
 order by 
		sum(oi.price + oi.freight_value) desc) as rk
from order_items oi
join orders_data o on o.order_id = oi.order_id
join product_dataset p on p.product_id = oi.product_id
where o.order_status = 'delivered'
group by 1,2) sq
where rk = 1
		


create table top_product_by_cancelled_order_per_year as 
select 
	year,
	product_category_name,
	num_cancelled
from(
	select
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		count(1) as num_cancelled,
		rank() over(partition by
							date_part('year', o.order_purchase_timestamp)
							order by count(1) desc) as rk
	from 	
		order_items oi 
	join orders_data o on oi.order_id = o.order_id 
	join product_dataset p on oi.product_id  = p.product_id 
	where o.order_status = 'canceled'
	group by 1,2
	) subq
	where rk = 1
	
	select 	
			a.year,
			a.product_category_name as top_product_category_per_revenuew,
			a.revenue as category_revenue,
			b.revenue as year_total_revenue,
			c.product_category_name as most_cancelled_product_category,
			c.num_cancelled as category_num_cancelled,
			d.order_canceled as year_total_num_cancelled
			
			
	from 
		top_product_category_by_revenue_per_year a
	join
		total_revenue_per_year  b on a."year"  = b."year"
	join 
		top_product_by_cancelled_order_per_year c on a."year" = c."year" 
	join 
		total_cance_order d on a."year" = c."year" 
	

	
	------------------------------------------------------------ Annual Payment Type Usage Analysis
	
	
	select 	
			op.payment_type,
			count(payment_installments) as sum_of_payment_use
	from 
			order_payments op 
	group by 1
	order by 2 desc;
	
	
	
	with sem as (
					select 
							date_part('year', od.order_purchase_timestamp) as year,
							op.payment_type,
							count(1) as num_used
					from
							orders_data od 
					join
							order_payments op on od.order_id = op.order_id 
	
					group by 1,2
	)
	
	select *,
	case when of_year_2017 = 0 then NULL
			else round((of_year_2018 - of_year_2017) / of_year_2017, 2)
	end as change_2017_2018
	from (
			select 
  					payment_type,
 					sum(case when year = '2016' then num_used else 0 end) as of_year_2016,
  					sum(case when year = '2017' then num_used else 0 end) as of_year_2017,
  					sum(case when year = '2018' then num_used else 0 end) as of_year_2018
			from sem 
			group by 1) subq
			order by 5 desc

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
			
		
