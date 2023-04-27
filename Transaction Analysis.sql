-- 1. How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales
---------------------------------------------------------------------------------------------------------------------

-- 2. What is the average unique products purchased in each transaction?
SELECT ROUND(AVG(unique_products) AS avg_products
FROM (SELECT s.txn_id, COUNT(s.prod_id) AS unique_products
      FROM sales AS s
      JOIN product_details AS pd
      ON s.prod_id=pd.product_id
      GROUP BY s.txn_id) AS sub_q
---------------------------------------------------------------------------------------------------------------------

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
SELECT PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY revenue ASC) AS percentile_25_revenue,
       PERCENTILE_CONT(0.50) WITHIN GROUP(ORDER BY revenue ASC) AS percentile_50_revenue,
	   PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY revenue ASC) AS percentile_75_revenue
FROM (SELECT txn_id, SUM(qty*price) AS revenue
      FROM sales
      GROUP BY txn_id) AS sub_q
---------------------------------------------------------------------------------------------------------------------

-- 4. What is the average discount value per transaction?
SELECT ROUND(AVG(discount)) AS avg_discount
FROM (SELECT txn_id, SUM(qty*price*discount)/100::INTEGER AS discount
      FROM sales
      GROUP BY txn_id) AS sub
---------------------------------------------------------------------------------------------------------------------
-- 5. What is the percentage split of all transactions for members vs non-members?
WITH cte AS (
    SELECT member, COUNT(DISTINCT txn_id)::INTEGER AS count_member, (SELECT COUNT(DISTINCT txn_id) FROM sales)::INTEGER AS total
    FROM sales
    GROUP BY member)
SELECT member, ROUND(count_member/total:: DECIMAL,2)*100
FROM cte
---------------------------------------------------------------------------------------------------------------------

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH cte AS (
    SELECT member, txn_id, SUM(price * qty) AS revenue
    FROM sales
    GROUP BY member, txn_id)
SELECT member, ROUND(AVG(revenue), 2) AS avg_revenue
FROM cte
GROUP BY member
