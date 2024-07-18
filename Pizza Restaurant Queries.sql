/*
Pizza Restaurant Case study project
*/

create database pizza_project
go

use pizza_project
go

select * from order_details  
go

select * from pizzas 
go

select * from orders  
go

select * from pizza_types
go


---1) Retrieve the total number of orders placed.

select 
  count(distinct order_id) as 'Total no of Orders' 
from 
  orders


---2) Calculate the total revenue generated from pizza sales.

select 
  cast(
    sum(
      order_details.quantity * pizzas.price
    ) as decimal(10, 2)
  ) as 'Total Revenue' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id


---3) Identify the highest-priced pizza using TOP/Limit functions

with cte as (
  select 
    pizza_types.name as 'Pizza_Name', 
    cast(
      pizzas.price as decimal(10, 2)
    ) as 'Price', 
    rank() over (
      order by 
        price desc
    ) as rnk 
  from 
    pizzas 
    join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
) 
select 
  Pizza_Name,
  Price
from 
  cte 
where 
  rnk = 1


---4) Identify the most common pizza size ordered.

select 
  pizzas.size, 
  count(distinct order_id) as 'No of Orders', 
  sum(quantity) as 'Total Quantity Ordered' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
group by 
  pizzas.size 
order by 
  count(distinct order_id) desc


---5) List the top 5 most ordered pizza types along with their quantities.

select 
  top 5 pizza_types.name as 'Pizza', 
  sum(quantity) as 'Total Ordered' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
  join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by 
  pizza_types.name 
order by 
  sum(quantity) desc


---6) Join the necessary tables to find the total quantity of each pizza category ordered.

select 
  top 5 pizza_types.category, 
  sum(quantity) as 'Total Quantity Ordered' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
  join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by 
  pizza_types.category 
order by 
  sum(quantity) desc


---7) Determine the distribution of orders by hour of the day.

select 
  datepart(hour, time) as 'Hour of the day', 
  count(distinct order_id) as 'No of Orders' 
from 
  orders 
group by 
  datepart(hour, time) 
order by 
  [No of Orders] desc


---8) find the category-wise distribution of pizzas.

select 
  category, 
  count(distinct pizza_type_id) as [No of pizzas] 
from 
  pizza_types 
group by 
  category 
order by 
  [No of pizzas]


---9) Calculate the average number of pizzas ordered per day.

with cte as(
  select 
    orders.date as 'Date', 
    sum(order_details.quantity) as 'Total Pizza Ordered that day' 
  from 
    order_details 
    join orders on order_details.order_id = orders.order_id 
  group by 
    orders.date
) 
select 
  avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day] 
from 
  cte


---10) Determine the top 3 most ordered pizza types based on revenue.

select 
  top 3 pizza_types.name, 
  sum(
    order_details.quantity * pizzas.price
  ) as 'Revenue from pizza' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
  join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by 
  pizza_types.name 
order by 
  [Revenue from pizza]
desc


---11) Calculate the percentage revenue contribution of each pizza type to total revenue.

select 
  pizza_types.category, 
  concat(
    cast(
      (
        sum(
          order_details.quantity * pizzas.price
        ) / (
          select 
            sum(
              order_details.quantity * pizzas.price
            ) 
          from 
            order_details 
            join pizzas on pizzas.pizza_id = order_details.pizza_id
        )
      )* 100 as decimal(10, 2)
    ), 
    '%'
  ) as 'Revenue contribution from pizza' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
  join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by 
  pizza_types.category 
order by 
  [Revenue contribution from pizza] 
desc


---12) Calculate the percentage contribution of each pizza name to total revenue.

select 
  pizza_types.name, 
  concat(
    cast(
      (
        sum(
          order_details.quantity * pizzas.price
        ) / (
          select 
            sum(
              order_details.quantity * pizzas.price
            ) 
          from 
            order_details 
            join pizzas on pizzas.pizza_id = order_details.pizza_id
        )
      )* 100 as decimal(10, 2)
    ), 
    '%'
  ) as 'Revenue contribution from pizza' 
from 
  order_details 
  join pizzas on pizzas.pizza_id = order_details.pizza_id 
  join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
group by 
  pizza_types.name 
order by 
  [Revenue contribution from pizza] 
desc


---13) Analyze the cumulative revenue generated over time.

with cte as (
  select 
    date as 'Date', 
    cast(
      sum(quantity * price) as decimal(10, 2)
    ) as Revenue 
  from 
    order_details 
    join orders on order_details.order_id = orders.order_id 
    join pizzas on pizzas.pizza_id = order_details.pizza_id 
  group by 
    date
) 
select 
  Date, 
  Revenue, 
  sum(Revenue) over (
    order by 
      date
  ) as 'Cumulative Sum' 
from 
  cte 
group by 
  date, 
  Revenue


---14) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
  select 
    category, 
    name, 
    cast(
      sum(quantity * price) as decimal(10, 2)
    ) as Revenue 
  from 
    order_details 
    join pizzas on pizzas.pizza_id = order_details.pizza_id 
    join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id 
  group by 
    category, 
    name
), 
cte1 as (
  select 
    category, 
    name, 
    Revenue, 
    rank() over (
      partition by category 
      order by 
        Revenue desc
    ) as rnk 
  from 
    cte
) 
select 
  category, 
  name, 
  Revenue 
from 
  cte1 
where 
  rnk in (1,2,3) 
order by 
  category, 
  name, 
  Revenue
