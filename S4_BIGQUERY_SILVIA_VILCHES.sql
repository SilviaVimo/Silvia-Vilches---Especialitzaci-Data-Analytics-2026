# NIVEL 1
-- EJERCICIO 1 

SELECT *
FROM `sprint3_silver.transactions_clean` AS transactions
JOIN `sprint3_silver.companies_clean` AS companies
USING(business_id)
WHERE companies.country = "Germany" AND DATE(timestamp) = "2022-03-12";

-- EJERCICIO 2 paso 1

CREATE OR REPLACE TABLE `sprint3_silver.transactions_recent` AS
SELECT * 
EXCEPT(timestamp),
TIMESTAMP_SUB(
              CURRENT_TIMESTAMP(),
              INTERVAL CAST(RAND() * 50 AS INT64) DAY
             ) AS timestamp
FROM `sprint3_silver.transactions_clean`;


-- EJERCICIO 2 paso 2

CREATE OR REPLACE TABLE `sprint3_gold.fact_transactions_optimized`
PARTITION BY DATE(timestamp)
CLUSTER BY business_id
OPTIONS (description = "a table clustered by business_id & partitioned by date")
AS
SELECT *
FROM `sprint3_silver.transactions_recent`;


-- EJERCICIO 3 pao 1

SELECT *
FROM `sprint3_silver.transactions_recent`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);

-- EJERCICIO 3 paso 2

SELECT *
FROM `sprint3_gold.fact_transactions_optimized`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);


-- EJERCICIO 4

CREATE MATERIALIZED VIEW sprint3_gold.mv_daily_sale AS (
SELECT DATE(timestamp) AS date,
COUNT(transaction_id) AS total_sales
FROM `sprint3_gold.fact_transactions_optimized`
GROUP BY date
ORDER BY date DESC
);

# NIVEL 2

-- EJERCICIO 1

WITH VIP_Stats AS
(
SELECT transactions_clean.user_id,
ROUND(SUM(transactions_clean.amount), 2) AS total_amount_user,
COUNT(transactions_clean.transaction_id) AS total_transactions,
ROUND(AVG(transactions_clean.amount), 2) AS avg_ticket,
MAX(transactions_clean.amount) AS max_purchase,
FROM `sprint3_silver.transactions_clean` as transactions_clean
GROUP BY transactions_clean.user_id
HAVING total_amount_user > 500)
SELECT users_combined.user_id, 
CONCAT(users_combined.name, ' ', users_combined.surname)  AS full_name,
users_combined.email, 
VIP_Stats.total_transactions, VIP_Stats.avg_ticket, VIP_Stats.max_purchase, VIP_Stats.total_amount_user
FROM VIP_Stats
INNER JOIN `sprint3_silver.users_combined` AS users_combined
USING(user_id)
ORDER BY VIP_Stats.total_amount_user DESC;

-- EJERCICIO 2


SELECT date, 
total_sales AS today_sales,
LAG(total_sales) OVER (ORDER BY date) AS yesterday_sales,
ROUND((total_sales - LAG(total_sales) OVER (ORDER BY date))/ LAG(total_sales) OVER (ORDER BY date) * 100, 2) AS percentage_sale
FROM `sprint3_gold.mv_daily_sale`
ORDER BY date DESC;


-- EJERCICIO 3

SELECT date, 
ROUND(total_sales, 2) AS sales_today,
ROUND(SUM(total_sales) OVER (PARTITION BY EXTRACT(YEAR FROM date)
                            ORDER BY date
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 
2) AS sales_YTD
FROM `sprint3_gold.mv_daily_sale`
ORDER BY date DESC;

-- EJERCICIO 4

WITH first_transactions AS (
SELECT user_id, amount, DATE(timestamp) AS purchase_date,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp) AS purchase_order
FROM `sprint3_gold.fact_transactions_optimized` 
QUALIFY purchase_order <= 3),

third_purchase AS (
SELECT user_id, amount, DATE(timestamp) AS purchase_date,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp) AS purchase_order
FROM `sprint3_gold.fact_transactions_optimized` 
QUALIFY purchase_order = 3)

SELECT users_combined.user_id,
CONCAT(users_combined.name, ' ', users_combined.surname) AS full_name,
users_combined.email,
third_purchase.purchase_order, third_purchase.amount,
ROUND(AVG(first_transactions.amount), 2) AS avg_first_transactions 
FROM `sprint3_silver.users_combined` AS users_combined
JOIN first_transactions
USING(user_id)
JOIN third_purchase
USING(user_id)
GROUP BY users_combined.user_id,full_name, users_combined.email, third_purchase.purchase_order, third_purchase.amount
ORDER BY avg_first_transactions DESC;


# NIVEL 3

-- EJERCICIO 1

CREATE OR REPLACE TABLE `sprint3_gold.dim_transactions_flat`AS (
SELECT transactions.transaction_id,
DATE(transactions.timestamp) AS purchase_date,
transactions.amount,
products.product_id,
products.name AS product_name,
products.price AS product_price
FROM `sprint3analyticssilvia.sprint3_gold.fact_transactions_optimized` AS transactions

CROSS JOIN UNNEST(SPLIT(transactions.product_ids)) AS product_id

INNER JOIN `sprint3analyticssilvia.sprint3_silver.products_clean` AS products
ON products.product_id = CAST(product_id AS INT64)
);


-- EJERCICIO 2

SELECT product_id,product_name,
COUNT(product_id) AS total_purchase
FROM `sprint3_gold.dim_transactions_flat`
GROUP BY product_id, product_name
ORDER BY total_purchase DESC
LIMIT 5;

-- EJERCICIO 3 paso 1

CREATE FUNCTION `sprint3_gold.calculate_tax`(amount FLOAT64)
RETURNS FLOAT64
AS (
  ROUND(amount * 1.21, 2)
);

-- EJERCICIO 3 paso 2

CREATE OR REPLACE TABLE `sprint3_gold.dim_transactions_flat`AS (
SELECT transactions.transaction_id,
DATE(transactions.timestamp) AS purchase_date,
transactions.amount,
products.product_id,
products.name AS product_name,
products.price AS product_price,
`sprint3_gold.calculate_tax`(products.price) AS product_price_tax_inc
FROM `sprint3analyticssilvia.sprint3_gold.fact_transactions_optimized` AS transactions
CROSS JOIN UNNEST(SPLIT(transactions.product_ids)) AS product_id
INNER JOIN `sprint3analyticssilvia.sprint3_silver.products_clean` AS products
ON products.product_id = CAST(product_id AS INT64)
);


