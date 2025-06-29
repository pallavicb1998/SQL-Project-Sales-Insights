/* Give me the highest selling product and its net sales per market*/

with cte as (
select fs.product_code, dc.market,sum(fs.sold_quantity) as total_qty_by_product
from fact_sales_monthly fs
left join dim_product dp
on fs.product_code = dp.product_code
left join dim_customer dc
on fs.customer_code = dc.customer_code
group by dc.market,fs.product_code)
,cte2 as (select *, dense_rank()over(partition by market order by total_qty_by_product desc) as rnk
from cte ) select * from cte2 where rnk=1;

/* Give me the top 2 markets for each region by gross_sales*/

with cte1 as(
select
	dc.market,
	dc.region,
	round(sum(gross_price_total)/1000000,2) as gross_sales_mln
	from gross_sales_view s
	join dim_customer dc
	on dc.customer_code=s.customer_code
	where fiscal_year=2021
	group by market,region
	order by gross_sales_mln desc
		),
		cte2 as (
			select *,
			dense_rank() over(partition by region order by gross_sales_mln desc) as drnk
			from cte1
		)
	select * from cte2 where drnk<=2;

/* Gross sales Invoice*/
    
    SELECT 
        `fs`.`date` AS `date`,
        `fs`.`fiscal_year` AS `fiscal_year`,
        `fs`.`customer_code` AS `customer_code`,
        `fs`.`product_code` AS `product_code`,
        `dp`.`product` AS `product`,
        `dp`.`variant` AS `variant`,
        `fs`.`sold_quantity` AS `sold_quantity`,
        `fgp`.`gross_price` AS `gross_price`,
        ROUND((`fgp`.`gross_price` * `fs`.`sold_quantity`),
                2) AS `gross_price_total`
    FROM
        (((`fact_sales_monthly` `fs`
        JOIN `dim_customer` `dc` ON ((`fs`.`customer_code` = `dc`.`customer_code`)))
        JOIN `dim_product` `dp` ON ((`fs`.`product_code` = `dp`.`product_code`)))
        JOIN `fact_gross_price` `fgp` ON (((`fgp`.`product_code` = `fs`.`product_code`)
            AND (`fgp`.`fiscal_year` = `fs`.`fiscal_year`))))

    
    
