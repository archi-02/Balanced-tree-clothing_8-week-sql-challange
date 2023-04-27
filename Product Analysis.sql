-- 1. What are the top 3 products by total revenue before discount?
SELECT pd.product_name, SUM(s.qty*s.price) AS revenue
FROM sales AS s
JOIN product_details AS pd
ON s.prod_id=pd.product_id
GROUP BY product_name
ORDER BY SUM(s.qty*s.price) DESC
LIMIT 3
---------------------------------------------------------------------------------------------------------------------

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT pd.segment_name, 
       SUM(s.qty) AS total_qty, 
       SUM(s.qty*s.price) AS total_revenue, 
       ROUND(SUM(s.qty*s.price*s.discount)/100) AS total_discount
FROM sales AS s
JOIN product_details AS pd
ON s.prod_id=pd.product_id
GROUP BY pd.segment_name
---------------------------------------------------------------------------------------------------------------------

-- 3. What is the top selling product for each segment?
WITH cte AS (
    SELECT pd.segment_name, pd.product_name, SUM(s.qty) AS total_quantity, 
	   RANK()OVER( PARTITION BY pd.segment_name ORDER BY SUM(s.qty)) AS ranking
    FROM sales AS s
    JOIN product_details AS pd
    ON s.prod_id=pd.product_id
    GROUP BY pd.segment_name, pd.product_name
    ORDER BY pd.segment_name)
SELECT segment_name, product_name
FROM cte
WHERE ranking=1
---------------------------------------------------------------------------------------------------------------------

-- 4. What is the total quantity, revenue and discount for each category?
SELECT pd.category_name, 
       SUM(s.qty) AS total_qty, 
       SUM(s.qty*s.price) AS total_revenue, 
       ROUND(SUM(s.qty*s.price*s.discount)/100) AS total_discount
FROM sales AS s
JOIN product_details AS pd
ON s.prod_id=pd.product_id
GROUP BY pd.category_name
---------------------------------------------------------------------------------------------------------------------

-- 5. What is the top selling product for each category?
WITH cte AS (
    SELECT pd.category_name, pd.product_name, SUM(s.qty) AS total_quantity,
           RANK()OVER(PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC) AS ranking
    FROM sales AS s
    JOIN product_details AS pd
    ON s.prod_id=pd.product_id
    GROUP BY pd.category_name, pd.product_name)
SELECT category_name, product_name AS top_seller
FROM cte
WHERE ranking=1
--------------------------------------------------------------------------------------------------------------------

-- 6. What is the percentage split of revenue by product for each segment?
SELECT segment_name, product_name, ROUND((total_revenue/total_revenue_per_segmenmt)*100,2) AS percentage_of_revenue
FROM (SELECT pd.segment_name, pd.product_name, SUM(s.qty*s.price) AS total_revenue,
             SUM(SUM(s.qty*s.price))OVER(PARTITION BY pd.segment_name) AS total_revenue_per_segmenmt
      FROM sales AS s
      JOIN product_details AS pd
      ON s.prod_id=pd.product_id
      GROUP BY pd.segment_name, pd.product_name
      ORDER BY pd.segment_name) AS sub_q
--------------------------------------------------------------------------------------------------------------------

-- 7. What is the percentage split of revenue by segment for each category?
SELECT category_name, segment_name, ROUND((total_revenue/total_revenue_per_segmenmt)*100,2) AS percentage_of_revenue
FROM (SELECT pd.category_name, pd.segment_name, SUM(s.qty*s.price) AS total_revenue,
             SUM(SUM(s.qty*s.price))OVER(PARTITION BY pd.category_name) AS total_revenue_per_segmenmt
      FROM sales AS s
      JOIN product_details AS pd
      ON s.prod_id=pd.product_id
      GROUP BY pd.category_name, pd.segment_name
      ORDER BY pd.category_name) AS sub_q
--------------------------------------------------------------------------------------------------------------------


-- 8. What is the percentage split of total revenue by category?
SELECT pd.category_name, 
       ROUND(SUM(s.qty*s.price)/SUM(SUM(s.qty*s.price))OVER()*100, 2) AS percent_revenue
FROM sales AS s
JOIN product_details AS pd
ON s.prod_id=pd.product_id
GROUP BY pd.category_name
--------------------------------------------------------------------------------------------------------------------

-- 9. What is the total transaction “penetration” for each product? 
/* (hint: penetration = number of transactions where at least 1 quantity 
   of a product was purchased divided by total number of transactions) */
WITH cte AS (
    SELECT pd.product_name, COUNT(DISTINCT s.txn_id) AS transactions_of_products, 
          (SELECT COUNT(DISTINCT txn_id)
		   FROM sales) AS total_transactions
    FROM sales AS s
    JOIN product_details AS pd
    ON s.prod_id=pd.product_id
    GROUP BY pd.product_name)
SELECT product_name, 
       ROUND((CAST(transactions_of_products AS NUMERIC)/CAST(total_transactions AS NUMERIC))*100,2) AS transaction_penetration
FROM cte
--------------------------------------------------------------------------------------------------------------------

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?