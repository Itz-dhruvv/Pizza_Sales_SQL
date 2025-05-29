-- Retrieve the total number of orders placed.
select count(order_id) total_orders
from orders;

-- Calculate the total revenue generated from pizza sales. 

select round(sum(order_details.quantity*pizzas.price),2) total_revenue
from order_details  
inner join pizzas  on 
order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price
from pizzas 
inner join pizza_types 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

-- either one of them both are correct..


select pizza_types.name, max(pizzas.price)
from pizzas 
inner join pizza_types 
on pizza_types.pizza_type_id = pizzas.pizza_type_id;


-- Identify the most common pizza size ordered.

select pizzas.size, count(order_details.quantity) order_cnt
from pizzas
inner join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by order_cnt desc ;

-- List the top 5 most ordered pizza types along with their quantities.

select  pizza_types.name,sum(order_details.quantity) quantity
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by count(order_details.quantity) desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select sum(order_details.quantity), pizza_types.category
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by count(order_details.quantity) desc

-- Determine the distribution of orders by hour of the day.

select hour(order_time), count(order_id)
from orders
group by hour(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select count(pizza_type_id), category
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(no_of_pizza),0) order_per_day
from(
select orders.order_date date, sum(order_details.quantity) no_of_pizza
from orders
inner join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) tbl;

-- Determine the top 3 most ordered pizza based on revenue.

select pizza_types.name, sum(pizzas.price * order_details.quantity) revenue
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select category, round((revenue/sum(revenue) over()*100),2)
from(
select pizza_types.category category, round(sum(pizzas.price * order_details.quantity),2) revenue
from pizza_types
inner join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc) tbl
group by category;

-- Analyze the cumulative revenue generated over time.


select order_date, revenue, sum(revenue) over(order by order_date) cumulative_renenue
from(
select orders.order_date, round(sum(pizzas.price * order_details.quantity),2) revenue
from order_details
inner join pizzas
on order_details.pizza_id = pizzas.pizza_id
inner join orders
on orders.order_id = order_details.order_id
group by orders.order_date) tbl;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, rnk 
from(
select category, name, revenue, rank() over(partition by category order by revenue desc) rnk
from(
select pizza_types.category, pizza_types.name , round(sum(pizzas.price * order_details.quantity), 2) revenue
from pizzas
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category,  pizza_types.name) tbl) tbl2
where rnk<=3;

