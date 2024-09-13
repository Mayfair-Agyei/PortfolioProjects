SELECT COUNT(customer_id)
FROM customers;
-- There are 795 customers in the database

SELECT o.shipping_city, SUM(od.order_profits) AS Total_profit,
		COUNT(DISTINCT o.order_id) AS Num_orders
FROM orders o
LEFT JOIN order_details od 
ON o.order_id = od.order_id
WHERE EXTRACT (YEAR FROM o.order_date)=2015
GROUP BY 1
ORDER BY 2 DESC;
--New York City was the most profitable city for the company in 2015 with $14,753 in profit

SELECT COUNT (DISTINCT shipping_city)
FROM orders;
-- Orders were shipped from 531 unique cities.

SELECT  cs.customer_id,SUM(order_sales) total_spent
FROM customers cs
LEFT JOIN orders o ON cs.customer_id = o.customer_id
LEFT JOIN order_details od ON  o.order_id = od.order_id
GROUP BY cs.customer_id
ORDER BY 2;
-- Lowest amount spent by a customer was $5

SELECT o.shipping_city, SUM(od.order_profits) AS Total_profit, COUNT(DISTINCT o.order_id) AS Num_orders
FROM orders o
JOIN order_details od 
ON o.order_id = od.order_id
WHERE shipping_state LIKE '%Tenne%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- Lebanon is most profitable city in Tennesse with $83 profit and 3 orders.customers


WITH yearly_profits AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(order_profits) AS annual_profit
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    WHERE shipping_city = 'Lebanon'
    GROUP BY 1
)
SELECT 
    AVG(annual_profit) AS avg_annual_profit
FROM yearly_profits;
-- The average annual profit for Lebanon across all years is 27.667

SELECT customer_segment,COUNT(customer_id) AS num_customer
FROM customers
GROUP BY 1;

SELECT p.product_category, AVG(od.order_profits) avg_profit
FROM product p
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON  od.order_id = o.order_id
WHERE shipping_state = 'Iowa'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- The most profitable product category in Iowa is Furniture with an average profit of 130.25 
--and the least profitable was office supply with 15.73


SELECT p.product_id, p.product_name, COUNT(DISTINCT o.order_id) As Num_orders, SUM(od.quantity) AS total_Qty
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN product p ON p.product_id = od.product_id
WHERE EXTRACT (YEAR FROM o.order_date) = 2016 AND p.product_category = 'Furniture'
GROUP BY 1,2
ORDER BY 4 DESC;
--The most popular product in Furniture in 2016 is 
--Global Push Button Manager's Chair', indigo with 22 qty 

 
SELECT customer_name, SUM((order_sales/(1 - order_discount)- order_sales))total_discount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
WHERE order_discount > 0
GROUP BY 1
ORDER BY 2 DESC;
-- Sean Miller got the most discount(in total amount) in the data

-- How widely did monthly profits vary in 2018
SELECT EXTRACT(MONTH FROM o.order_date) AS month,
			 SUM(od.order_profits) AS sum_order_profit,
       SUM(od.order_sales) AS total_sales,
       ROUND((SUM(od.order_profits)/SUM(od.order_sales))::NUMERIC,3) AS total_profit_ratio
FROM order_details od
LEFT JOIN orders o
ON od.order_id = o.order_id
WHERE EXTRACT (YEAR FROM order_date) = 2018
GROUP BY 1
ORDER BY 1;


SELECT o.order_id, SUM(od.order_sales) total_sales
FROM order_details od
LEFT JOIN orders o ON od.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2015
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- The bigest order sale was from order_id CA-2015-145317 and was 23660. 
--Least was CA-2015-112403 with 1 as sales price

-- Rank of each city in the East region in 2015 in quantity
SELECT o.shipping_city, SUM(od.quantity) AS Qty,
RANK() OVER (ORDER BY SUM(quantity) DESC) AS
cityrank
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE shipping_region = 'East' AND EXTRACT (YEAR FROM o.order_date)=2015
GROUP BY 1;


SELECT MAX(quantity) - MIN (quantity) AS qty_difference
FROM order_details
WHERE product_id = 100;
--The difference between the largest and smallest order quantities for product id '100' is 4.



SELECT CONCAT(ROUND((SELECT COUNT(product_category):: NUMERIC
										 FROM product
										 WHERE product_category = 'Furniture'
 										 GROUP BY product_category)/COUNT(product_category)*100,2),'%') perc_furniture
FROM product;
--The percentage of Furniture products is 20.54%.

--The number of product manufacturers with more than 1 product in the product table
SELECT product_manufacturer, COUNT(DISTINCT product_id)
FROM product
GROUP BY 1
HAVING COUNT(DISTINCT product_id)>1
ORDER BY 2 DESC;


--The product_subcategory and the total number of products in the subcategory. 
--The order from most to least products and then by product_subcategory name ascending
SELECT 
product_subcategory,
       COUNT(*) AS total_products
FROM product
GROUP BY 1
ORDER BY 2 DESC, 1 ;
;


--Product_id(s) and sum of quantities, where the total sum of its product quantities 
--is greater than or equal to 100
SELECT product_id,SUM(quantity) AS total_quantities
FROM order_details
GROUP BY 1
HAVING SUM(quantity) >= 100
ORDER BY 2 DESC;













