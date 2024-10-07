#Pizzahut Pizza sales Analysis Using SQL

#Basics:
-- Q1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_Orders
FROM
    orders;
    

-- Q2.Calculate the total revenue generated from pizza sales.
SELECT 
    format(SUM(order_details.quantity * pizzas.price),
            "C") AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
-- round() is used for assign decimal places after number


-- Q3.Identify the highest-priced pizza.
SELECT 
    name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Q4.Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_details.quantity) AS orders
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY size order by orders desc;


-- Q5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantities DESC
LIMIT 4;




#Intermediate
-- Q.1 Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, format(SUM(od.quantity),"C") AS total_quantity
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY SUM(od.quantity) DESC;


-- Q.2 Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY hours
ORDER BY total_orders DESC;


-- Q.3 Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pt.category, COUNT(pt.pizza_type_id) AS total_pizzas
FROM
    pizza_types AS pt
        INNER JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_pizzas DESC;


-- Q.4 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_orders), 0) AS Average_orders_per_day
FROM
    (SELECT 
        DAY(order_date) AS order_day,
            COUNT(order_id) AS total_orders
    FROM
        orders
    GROUP BY order_day
    ORDER BY total_orders DESC) AS total_orders_per_day; 


-- Q.5 Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name,
    FORMAT(SUM(od.quantity * p.price), 'C') AS Total_revenue
FROM
    order_details AS od
        INNER JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
        INNER JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;




#Advanced:
-- Q.1 Calculate the percentage contribution of each pizza type to total revenue.
#Created a view to Simplify the Query
#Solved Using Sub_Query:
Create view Total_revenue as (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id);
SELECT 
    pizza_types.category AS Pizza_type,
    ROUND(SUM(order_details.quantity * pizzas.price) / (select * from Total_revenue) * 100 ,
            2) AS Total_revenue_percentage
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_revenue_percentage DESC;





-- Q.2 Analyze the cumulative revenue generated over time.
#Solve using windows function and aggrigate function:
SELECT order_date,format(sum(revenue) over(order by order_date),"C")
AS Cumulative_revenue
FROM
 (SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.order_date)as cm ;



-- Q.3 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
#Solved using windows function rank():
select category,name,Total_revenue from
(select category,name,Total_revenue,rank()over(partition by category order by Total_revenue desc )as ranking from(
(SELECT 
    pizza_types.category,pizza_types.name,
    FORMAT(SUM(order_details.quantity * pizzas.price),
        'C') AS Total_Revenue
FROM
    pizzas
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        INNER JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category,pizza_types.name))as top)as rnk where ranking<=3;
