# NIVEL 1

-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:
-- Llistat dels països que estan generant vendes.

SELECT company.country
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company.country;


-- Des de quants països es generen les vendes.

SELECT COUNT(distinct company.country) AS countries
FROM company
JOIN transaction
ON company.id = transaction.company_id;


-- Identifica la companyia amb la mitjana més gran de vendes.


SELECT company.company_name,
AVG(transaction.amount) AS avg_company
FROM transaction
JOIN company
ON company.id = transaction.company_id
WHERE transaction.declined = FALSE
GROUP BY company.company_name
ORDER BY avg_company DESC
LIMIT 1;




-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT id
FROM transaction
WHERE company_id IN (SELECT id
					FROM company
					WHERE country = "Germany")
AND declined = FALSE;

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

SELECT company_name
FROM company
WHERE id IN (
			SELECT company_id
			FROM transaction
			WHERE amount > (
							SELECT AVG(amount)
							FROM transaction
                            WHERE declined = FALSE
							)
			);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT company_name
FROM company
WHERE id NOT IN (
    SELECT company_id
    FROM transaction
);       
           


-- Exercici 5
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938.
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938";

SELECT * 
FROM credit_card
WHERE id = "CcU-2938";

    
-- Exercici 6
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:

ALTER TABLE transaction
DROP FOREIGN KEY company_id; 

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", "111.11", "0");

INSERT INTO credit_card (id)
VALUES ("CcU-9999");

INSERT INTO company (id)
VALUES ("Nueva empresa");

SELECT * FROM transaction;

ALTER TABLE transaction
ADD CONSTRAINT fk_company_id
FOREIGN KEY (company_id) REFERENCES company(id);


DELETE FROM company WHERE id = "Nueva empresa";
DELETE FROM credit_card WHERE id = "CcU-9999";

-- Exercici 7
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.


SELECT *
FROM credit_card;

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;


-- Exercici 8
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar 
-- les següents consultes:

   -- Creamos la tabla companies
    CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(100),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

-- Creamos la tabla credit_cards
CREATE TABLE IF NOT EXISTS credit_cards (
		id VARCHAR(150) PRIMARY KEY,
        user_id VARCHAR(250),
        iban VARCHAR(100),
        pan VARCHAR(100),
        pin VARCHAR(100),
        cvv VARCHAR(100),
        track1 VARCHAR(250),
        track2 VARCHAR(250),
        expiring_date VARCHAR(150)
    );




-- Creamos la tabla european_users
CREATE TABLE IF NOT EXISTS european_users (
	id VARCHAR(40) PRIMARY KEY,
	name VARCHAR(40), 
	surname VARCHAR(40),
	phone VARCHAR(40), 
	email VARCHAR(40),
	birth_date VARCHAR(40),
	country VARCHAR(40),
	city VARCHAR(40), 
	postal_code VARCHAR(40), 
	address VARCHAR(40)
);

-- Creamos la tabla american_users
CREATE TABLE IF NOT EXISTS american_users (
	id VARCHAR(40) PRIMARY KEY,
	name VARCHAR(40), 
	surname VARCHAR(40),
	phone VARCHAR(40), 
	email VARCHAR(40),
	birth_date VARCHAR(40),
	country VARCHAR(40),
	city VARCHAR(40), 
	postal_code VARCHAR(40), 
	address VARCHAR(40)
);


    -- Creamos la tabla transactions
    CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(150) REFERENCES credit_cards(id),
        company_id VARCHAR(200) REFERENCES companies(company_id),
        timestamp TIMESTAMP,
        amount DECIMAL(65, 2),
        declined BOOLEAN,
        product_ids VARCHAR(200),
        user_id VARCHAR(100) REFERENCES european_users(id),
        lat FLOAT,
        longitude FLOAT
    );
    

SELECT @@secure_file_priv;
   
-- cargamos los archivos csv en cada una de las tablas creadas

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1.Ex.8__ companies.csv"
INTO TABLE companies 
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1.Ex.8__ credit_cards.csv"
INTO TABLE credit_cards 
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1.Ex.8__ european_users.csv"
INTO TABLE european_users 
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__ american_users.csv"
INTO TABLE american_users 
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1.Ex.8__ transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ";"
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- Exercici 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.


SELECT global_users.id, global_users.name, global_users.surname
FROM (	SELECT * FROM european_users
		UNION
		SELECT * FROM american_users ) AS global_users
JOIN (	SELECT user_id, 
		COUNT(id) AS transaction_by_user
		FROM transactions
		WHERE declined = 0
		GROUP BY user_id
		HAVING transaction_by_user > 80) AS transactions_user80
ON global_users.id = transactions_user80.user_id;


-- Exercici 10
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.


SELECT credit_cards.iban, credit_cards.id,
AVG(transactions.amount) avg_transaction
FROM transactions
JOIN credit_cards
ON transactions.credit_card_id = credit_cards.id
JOIN companies
ON transactions.company_id = companies.company_id
WHERE transactions.declined = FALSE
AND companies.company_name = "Donec Ltd"
GROUP BY credit_cards.iban, credit_cards.id;



# NIVEL 2

-- Exercici 1
-- Identifica los cinco días en los que la empresa generó mayores ingresos por ventas. ¿qué empresa?
-- Indica la fecha de cada transacción junto con el total de ventas.

SELECT DATE(timestamp) AS top_date, # para extrar solo la fecha de cada registro y que no aparezca la hora
SUM(amount) AS total_amount
FROM transactions
WHERE declined = FALSE
GROUP BY DATE(timestamp)
ORDER BY total_amount DESC
LIMIT 5;

-- Ejercicio 2
-- Presenta el nombre, el número de teléfono, el país, la fecha y el importe de aquellas empresas que realizaron transacciones 
-- por un valor comprendido entre 350 y 400 euros en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
-- Ordena los resultados en orden descendente por cantidad.


SELECT companies.company_name, companies.phone, companies.country, transactions.amount, 
DATE(transactions.timestamp) AS date_transactions
FROM transactions
JOIN companies
ON transactions.company_id = companies.company_id
WHERE transactions.amount BETWEEN 350 AND 400
  AND DATE(transactions.timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY transactions.amount DESC;


-- Ejercicio 3
-- Necesitamos optimizar la asignación de recursos, lo cual dependerá de la capacidad operativa requerida. 
-- Por lo tanto, te solicitamos información sobre el número de transacciones realizadas por las empresas. 
-- Sin embargo, el departamento de Recursos Humanos está siendo exigente y quiere una lista de las empresas en la que se especifique 
-- si tienen 400 o más transacciones, o menos.


SELECT companies.company_id, companies.company_name,
COUNT(transactions.id) AS num_transactions,
CASE WHEN COUNT(transactions.id) >= 400 THEN "More than 400"
	 ELSE "400 or less"
     END AS transaction_filter
FROM companies
LEFT JOIN transactions
ON companies.company_id = transactions.company_id
GROUP BY companies.company_id,
companies.company_name;

-- Ejercicio 4
-- Elimina el registro con el ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la tabla de transacciones de la base de datos.

DELETE FROM transactions
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

-- Ejercicio 5
-- El departamento de marketing desea acceder a información específica para llevar a cabo análisis y estrategias eficaces. 
-- Se ha solicitado una vista que proporcione datos clave sobre las empresas y sus transacciones. 
-- Deberás crear una vista denominada «MarketingView» que contenga la siguiente información: 
-- Nombre de la empresa. Teléfono de contacto. País de residencia. Compra media realizada por cada empresa. 
-- Presenta la vista creada, ordenando los datos de mayor a menor según la compra media.

SELECT companies.company_name, companies.phone, companies.country,
avg_table.avg_company
FROM companies
LEFT JOIN (	SELECT transactions.company_id,
			AVG(transactions.amount) AS avg_company
			FROM transactions
			GROUP BY transactions.company_id
			ORDER BY avg_company DESC) AS avg_table
ON companies.company_id = avg_table.company_id;


# NIVEL 3

-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito en función de si las tres últimas transacciones han sido rechazadas; 
-- si es así, la tarjeta está inactiva; en caso contrario, está activa. A partir de esta tabla, responde a lo siguiente:
-- 👉 ¿Cuántas tarjetas están activas?


CREATE TABLE  credit_card_status AS
WITH transactions_ranked AS (
			SELECT credit_card_id, declined,
			ROW_NUMBER() OVER(PARTITION BY credit_card_id ORDER BY DATE(timestamp) DESC) AS credit_card_rank
			FROM transactions
            )
SELECT credit_card_id,
CASE 
	WHEN SUM(declined) = 3 THEN 'inactive'
	ELSE 'active'
    END AS status
FROM transactions_ranked
GROUP BY credit_card_id;



SELECT COUNT(status) as active_cc
FROM credit_card_status
WHERE status = "active";


-- Ejercicio 2
-- Crea una tabla para unir los datos del archivo new products.csv con la base de datos creada, teniendo en cuenta que dispones de los product_ids
-- de la tabla de transacciones. Genera la siguiente consulta:
-- 👉 Necesitamos saber el número de veces que se ha vendido cada producto.

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10,2),
    colour VARCHAR(50),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(50)
);

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N3.Ex.2__ products.csv"
INTO TABLE products
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS
SET price = CAST(REPLACE(TRIM(@price), '$', '') AS DECIMAL(10,2));


SELECT products.id, products.product_name,
COUNT(transactions.product_ids) AS num_sold
FROM transactions
JOIN products
ON transactions.product_ids = products.id
GROUP BY products.id, products.product_name
ORDER BY products.id ASC;

