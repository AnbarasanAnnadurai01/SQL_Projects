use pizza;
/* Retrieve the total number of orders placed */

SELECT 
    COUNT(order_id) AS total_order_placed
FROM
    orders;

-- Calculate the total revenue generated from pizza sales --

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza -- 

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        LEFT JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;

-- Identify the most common pizza size ordered--

SELECT 
     p.size, COUNT(od.quantity) as most_ordered
FROM
    order_details od
        LEFT JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities --
with top5 as
(SELECT 
     p.pizza_id,p.pizza_type_id, sum(od.quantity) as most_ordered
FROM
    order_details od
         JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY 1,2
ORDER BY 3 DESC
)
select 
   pt.name,t5.most_ordered
from pizza_types pt
join top5 t5
on t5.pizza_type_id = pt.pizza_type_id
order by 2 desc;


select 
  pt.name,p.pizza_type_id,sum(ot.quantity) as most_quantites
from pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id 
join order_details ot
on ot.pizza_id = p.pizza_id
group by 1,2
order by 3 desc
Limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered

select 
  pt.category,sum(ot.quantity) as most_quantites
from pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id 
join order_details ot
on ot.pizza_id = p.pizza_id
group by 1;

-- Determine the distribution of orders by hour of the day --

SELECT 
    HOUR(time) AS time_in_hours, COUNT(order_id)
FROM
    orders
GROUP BY 1;

-- Join relevant tables to find the category-wise distribution of pizzas --

select 
  category, count(name) as pizza_name
  from pizza_types
  group by 1;
  
  -- Group the orders by date and calculate the average number of pizzas ordered per day --
select  Round(avg(order_pizza_per_day),0) as average_pizza_ordered_by_day from 
(select 
    o.date, sum(od.quantity) as order_pizza_per_day
from order_details od
join orders o
on od.order_id = o.order_id
group by 1) as quantity_pizza_per_day;

-- Determine the top 3 most ordered pizza types based on revenue --

select 
     pt.category, round(sum(od.quantity * p.price),2) as total_revenue 
from order_details od
join pizzas p 
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue --


select
 pt.category, round(round(sum(od.quantity * p.price),2) / (select  round(sum(od.quantity * p.price),2)
from order_details od
join pizzas p 
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id)*100,2) as Percentage
from order_details od
join pizzas p 
on p.pizza_id = od.pizza_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by 1;


-- Analyze the cumulative revenue generated over time --
select 
  date,
  sum(revenue) over(order by date) as cum_revenue
  from
(select 
  o.date,
  round(sum(od.quantity * p.price),2) as revenue
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
join orders o
on o.order_id = od.order_id
group by 1) as tr;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category -- 

select 
    category,name,revenue,rank_no
    from 
(select 
   category,name, revenue,
   rank() over(partition by category order by revenue desc ) as rank_no
   from (select 
  pt.category, pt.name,
  round(sum(od.quantity * p.price),2) as revenue
from order_details od
join pizzas p
on od.pizza_id = p.pizza_id
join orders o
on o.order_id = od.order_id
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id
group by 1,2
order by 3 desc) as top3) as b
where rank_no <=3

