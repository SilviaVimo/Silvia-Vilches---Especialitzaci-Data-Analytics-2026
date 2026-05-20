-- nivel 1

-- EJERCICIO 1

CREATE SCHEMA sprint3analyticssilvia.sprint3_silver 
OPTIONS (location = 'europe-southwest1');


-- EJERCICIO 2. Ingesta en Capa Bronze (Connexió DDL)

# CREAR TABLA TRANSACTIONS
CREATE EXTERNAL TABLE sprint3_bronze.transactions_raw
OPTIONS (
format = 'CSV',
uris  = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
skip_leading_rows = 1,
field_delimiter = ';'
);


# CREAR TABLA COMPANIES

CREATE EXTERNAL TABLE sprint3_bronze.companies_raw (
company_id STRING,
company_name STRING,
phone STRING,
email STRING,
country STRING,
Website STRING
)
OPTIONS (
format  = 'CSV',
uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
skip_leading_rows = 1
);


# CREAR TABLA CREDIT_CARDS
CREATE EXTERNAL TABLE sprint3_bronze.credit_cards_raw
OPTIONS (
format = 'CSV',
uris  = ['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv'],
skip_leading_rows = 1
);


# CREAR TABLA AMERICAN_USERS
CREATE EXTERNAL TABLE sprint3_bronze.american_users_raw
OPTIONS (
format = 'CSV',
uris  = ['gs://bootcamp-data-analytics-public/CRM/american_users.csv'],
skip_leading_rows = 1
);


# CREAR TABLA EUROPEAN_USERS
CREATE EXTERNAL TABLE sprint3_bronze.european_users_raw
OPTIONS (
format = 'CSV',
uris  = ['gs://bootcamp-data-analytics-public/CRM/european_users.csv'],
skip_leading_rows = 1
);

-- EJERCICIO 4

# A. CREAR TABLA TRANSACTIONS NATIVA 

CREATE TABLE sprint3_bronze.transactions_raw_native
AS
SELECT * FROM sprint3_bronze.transactions_raw;

# B. COSTE DE LEER LA MISMA CONSULTA

SELECT id
FROM `sprint3_bronze.transactions_raw_native`;

SELECT id
FROM `sprint3_bronze.transactions_rawe`;

# C. COSTE CON Y SIN LIMIT

SELECT *
FROM `sprint3_bronze.transactions_raw_native`;

SELECT *
FROM `sprint3_bronze.transactions_raw_native`
LIMIT 10;

-- EJERCICIO 5 ADAPTACIÓN DE SINTAXIS

SELECT
DATE(CAST(timestamp AS TIMESTAMP))  AS date,
ROUND(SUM(amount),2) AS total_amount
FROM `sprint3_bronze.transactions_raw`
WHERE EXTRACT(YEAR FROM CAST(timestamp AS TIMESTAMP)) = 2021
AND declined = 0
GROUP BY date
ORDER BY total_amount DESC
LIMIT 5;


-- EJERCICIO 6 CONSULTAS COMPLEJAS

SELECT t2.company_name, t2.country,date(t1.timestamp) AS date,
FROM 
`sprint3_bronze.transactions_raw_native` AS t1
INNER JOIN 
`sprint3_bronze.companies_raw` AS t2
ON t2.company_id = t1.business_id
WHERE t1.amount BETWEEN 100 AND 200
AND date(t1.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13');

-- nivel 2

-- EJERCICIO 1

CREATE OR REPLACE TABLE `sprint3_silver.products_clean` AS
SELECT
id AS product_id,
product_name AS name,
CAST(price AS FLOAT64) AS price,
weight,
colour,
CAST(REPLACE(warehouse_id, 'WH-', '') AS INT64) AS warehouse_id,
FROM `sprint3_bronze.products`;

-- EJERCICIO 2.

CREATE OR REPLACE TABLE `sprint3_silver.transactions_clean` AS
SELECT
id AS transaction_id,
card_id,
business_id,
CAST(timestamp AS TIMESTAMP) AS timestamp,
IFNULL(SAFE_CAST(amount AS FLOAT64), 0) AS amount,
declined,
product_ids,
user_id,
SAFE_CAST(lat AS FLOAT64) AS lat,
SAFE_CAST(longitude AS FLOAT64) AS longitude,
FROM `sprint3_bronze.transactions_raw`;

-- EJERCICIO 3. UNION

CREATE OR REPLACE TABLE sprint3_silver.users_combined AS
SELECT
id AS user_id,
name,
surname,
phone,
email,
birth_date,
country,
city,
postal_code,
address,
'USA' AS origin
FROM sprint3_bronze.american_users_raw

UNION ALL

SELECT
id AS user_id,
name,
surname,
phone,
email,
birth_date,
country,
city,
postal_code,
address,
'EU' AS origin
FROM sprint3_bronze.european_users_raw;


-- EJERCICIO 4

CREATE OR REPLACE TABLE `sprint3_silver.companies_clean` AS 
SELECT
company_id AS business_id,
company_name,
phone,
email, 
country,
Website,
FROM `sprint3_bronze.companies_raw`;


CREATE OR REPLACE TABLE `sprint3_silver.credits_cards_clean` AS 
SELECT
id AS card_id,
user_id,
iban,
pan,
pin,
cvv,
track1,
track2,
expiring_date,
FROM `sprint3_bronze.credit_cards_raw`;


# nivel 3

-- EJERCICIO 1

CREATE VIEW `sprint3analyticssilvia.sprint3_gold.v_marketing_kpis`
AS
SELECT
companies.company_name,
companies.phone,
companies.country,
AVG(transactions.amount) AS avg_purchase,
CASE
    WHEN AVG(transactions.amount) > 260 THEN "Premium"
    ELSE "Standard"
    END
    AS client_tier
FROM `sprint3analyticssilvia.sprint3_silver.companies_clean` AS companies
INNER JOIN
  `sprint3analyticssilvia.sprint3_silver.transactions_clean` AS transactions
USING(business_id)
GROUP BY companies.company_name, companies.phone, companies.country;

-- ENTREGA CONSULTA

SELECT *
FROM `sprint3analyticssilvia.sprint3_gold.v_marketing_kpis`
ORDER BY client_tier ASC, avg_purchase DESC;


-- EJERCICIO 2

CREATE TABLE sprint3_gold.product_sales_ranking AS
SELECT products_clean.product_id, products_clean.name, products_clean.price, products_clean.colour,
COUNT(product_table.product_id) AS total_sold
FROM `sprint3_silver.products_clean` AS products_clean
LEFT JOIN (SELECT CAST(product_id AS INT64) AS product_id
           FROM `sprint3_silver.transactions_clean`,
           UNNEST(SPLIT(product_ids, ', ')) AS product_id) AS product_table
ON products_clean.product_id = product_table.product_id
GROUP BY products_clean.product_id, products_clean.name, products_clean.price, products_clean.colour;

-- EJERCICIO 3
SELECT *
FROM `sprint3_gold.product_sales_ranking`
ORDER BY total_sold DESC;
