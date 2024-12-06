/*1. Coffee Consumers Count
   How many people in each city are estimated to consume coffee, 
   given that 25% of the population does? */
   
   select city_name, round(population * 0.25) as people_consumecoffee
   from city 
   order by 2 desc;
   
   
/* 2. Total Revenue from Coffee Sales  
   What is the total revenue generated from coffee sales across
   all cities in the last quarter of 2023? */
   
   select c.city_name , sum(s.total) as total_sales_citywise
   from city c   
   left join  customers cs 
   on c.city_id = cs.city_id
   left join sales_1 s
   on s.customer_id = cs.customer_id
   where quarter(s.sale_date) = 4
   group by 1
   order by 2 desc ;
   
/* 3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold? */
   
   select p.product_name, count(p.product_id) as no_of_product_sold
   from sales_1 s
   left join products p 
   on s.product_id = p.product_id
   group by 1;
   
   create temporary table product_sold as
   select p.product_name, count(p.product_id) as no_of_product_sold
   from sales_1 s
   left join products p 
   on s.product_id = p.product_id
   group by 1;
   
  select product_name, no_of_product_sold
  from product_sold 
  order by no_of_product_sold desc 
  limit 1;
  
  select product_name, no_of_product_sold
  from product_sold 
  order by no_of_product_sold asc
  limit 1;

  
/* 4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city? */
   
   select c.city_name ,round(sum(s.total)) / round(count(distinct s.customer_id)) as average_sales_per_customer
   from city c   
   left join  customers cs 
   on c.city_id = cs.city_id
   left join sales_1 s
   on s.customer_id = cs.customer_id
   group by 1;

/* 5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers. */
   
   select city_name, population, round(population*0.25) as estimated_coffee_consumers
   from city
   group by city_name , population;
   
/* 6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume? */ 
   
 select * 
 from 
 (select c.city_name ,
         p.product_name , 
		 count(s.sale_id) as total_sales,
  DENSE_RANK() OVER(PARTITION BY c.city_name  ORDER BY COUNT(s.sale_id) DESC) as rank_no
   from city c
   left join customers cs
   on c.city_id = cs.city_id
   left join sales_1 s
   on s.customer_id = cs.customer_id
   left join products p
   on p.product_id = s.product_id
   group by 1, 2) as t1
   where rank_no <=3;
   
/* **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products? */
   
   select c.city_name , count(distinct cs.customer_id)  as unique_customer_purchased
   from city c   
   left join  customers cs 
   on c.city_id = cs.city_id
   left join sales_1 s
   on s.customer_id = cs.customer_id
   left join  products p
   on p.product_id = s.product_id
   group by c.city_name;
   
/* 8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer */
 
 select c.city_name, round((sum(s.total)) / count(cs.customer_id)) as average_sale_percustomer ,
 round((max(estimated_rent))/ count(cs.customer_id))  as average_rent_per_customer
 from city c   
 left join  customers cs 
 on c.city_id = cs.city_id
 left join sales_1 s
 on s.customer_id = cs.customer_id
   left join  products p
   on p.product_id = s.product_id
   group by c.city_name ;


/*9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly). */

select 
	year(sale_date) as Years,
	monthname(sale_date) as months,
	sum(total),
	Lag ( sale_date, 1 , 0) over (partition by sale_date order by sum(total) asc) as previous_month
from sales_1
group by 1,2
order by 1 asc

/*10. /* **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, 
    total sale, total rent, total customers, estimated  coffee consumer */
    
    select  c.city_name , count(s.sale_id) as total_sales,sum(s.total) as total_amount,
    sum(c.estimated_rent) as total_rent, 
    count(distinct s.customer_id) as total_customers,
    round(max(c.population * 0.25)) as estimated_coffee_consumer
    from sales_1 s
    left join customers cs 
    on s.customer_id = cs.customer_id
    left join city c
    on c.city_id = cs.city_id
    group by  c.city_name
    order by total_sales desc
    Limit 3;
    







