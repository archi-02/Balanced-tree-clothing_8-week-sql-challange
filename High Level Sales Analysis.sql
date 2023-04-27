-- High Level Sales Analysis

-- 1. What was the total quantity sold for all products?
SELECT SUM(qty) AS total_products_sold
FROM sales
---------------------------------------------------------------------------------------------------------------------

-- 2. What is the total generated revenue for all products before discounts?
SELECT SUM(qty*price) AS total_revenue
FROM sales
---------------------------------------------------------------------------------------------------------------------

-- 3. What was the total discount amount for all products?
SELECT SUM((qty*price)*(discount))/100 AS total_revenue
FROM sales