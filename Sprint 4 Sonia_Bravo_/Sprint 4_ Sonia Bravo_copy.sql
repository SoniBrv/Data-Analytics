### Sonia Bravo ###
##Tasca 4.01. Creació de Base de Dades 

/*Nivell 1 SPRINT 4
Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
- Exercici 1
Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.*/

CREATE DATABASE IF NOT EXISTS transactions_2;
USE transactions_2;

##Creació de taula
CREATE TABLE IF NOT EXISTS Companies 
(company_id varchar (50) primary key NOT NULL,
company_name varchar(100),
phone VARCHAR (50),
email VARCHAR  (100),
country VARCHAR (50),		## Comentar que no es INT por si empieza por 0
website varchar (100));

##DROP TABLE Credit_card;
SHOW CREATE TABLE Companies;  
SHOW VARIABLES LIKE "secure_file_priv";  

/*Consultas y pruebas para ubicar el archivo en la carpeta privada
secure-file-priv="ruta_especifica";
SHOW VARIABLES LIKE 'local_infile';     ## Verificar si local_infile está activado en el servidor
SET GLOBAL local_infile = 1;   ##Si el resultado es OFF, necesitas activarlo. Activarlo temporalmente. Si solo necesitas activarlo para la sesión actual, ejecuta:
Poner en la hoja de texto detrás de mysql --local-infile=1 -u usuario -p;
SET GLOBAL local_infile = 1;  ##Activarlo temporalmente
net stop mysql;
net start mysql;
SELECT @@global.secure_file_priv;  ##(Para saber la ruta donde guardar el archivo de donde lo va a cargar)*/

CREATE TABLE IF NOT EXISTS Credit_card
(id varchar (50) primary key NOT NULL,
user_id int,  			##No poner caracteres en INT
iban VARCHAR (50),
pan VARCHAR  (100),
pin VARCHAR (50),		## Comentar que no es INT por si empieza por 0
cvv varchar (100),
track1 varchar (100),
track2 varchar (100),
expiring_date DATE);

CREATE TABLE IF NOT EXISTS Products
(id VARCHAR (50) primary key NOT NULL,
product_name varchar (50),  			
price VARCHAR (50),
colour VARCHAR  (100),
weight VARCHAR (50),		
warehouse_id varchar (155));

CREATE TABLE IF NOT EXISTS Users
(id varchar (255) primary key NOT NULL,
name varchar (50),  			
surname VARCHAR (50),
phone VARCHAR (50),
email varchar (100),	
birth_date VARCHAR (50),
country VARCHAR (50),
city	VARCHAR (50),	
postal_code  VARCHAR (50),	
address  VARCHAR (255));

CREATE TABLE IF NOT EXISTS Transactions
(id varchar (255) NOT NULL,
card_id varchar (50),  			
business_id VARCHAR (50),
timestamp TIMESTAMP,
amount INT,		
declined boolean,
product_ids VARCHAR (50),
user_id	VARCHAR (50),	
lat  VARCHAR (50),	
longitude  VARCHAR (50),
FOREIGN KEY (card_id) REFERENCES credit_card (id),
FOREIGN KEY (business_id) REFERENCES companies (company_id),
FOREIGN KEY (user_id) REFERENCES users (id));


## Càrrega d'arxius##
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE transactions_2.companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;					

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE transactions_2.credit_card
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'    ##\r\n Retorno de nueva línea##
IGNORE 1 ROWS
(id, user_id, iban, @pan, pin, cvv, track1, track2, @expiring_date)
SET 
pan = REPLACE (@pan, ' ',''),
expiring_date = STR_TO_DATE (@expiring_date, '%m/%d/%y');


##NO hace falta##
##ALTER TABLE credit_card MODIFY COLUMN expiring_date DATE; ##CONVIERTO EN DATE##

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE transactions_2.products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;		

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE transactions_2.users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'	 ##Como es un archivo WIndows CRLF cada línea, de manera oculta, acaba en \r\n;##
IGNORE 1 ROWS;	

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE transactions_2.users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'	 ##Como es un archivo WIndows CRLF cada línea, de manera oculta, acaba en \r\n;##
IGNORE 1 ROWS;	

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE transactions_2.users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'	 ##Como es un archivo WIndows CRLF cada línea, de manera oculta, acaba en \r\n;##
IGNORE 1 ROWS;	

/*SELECT id, COUNT(*) 
FROM transactions_2.users
GROUP BY id
HAVING COUNT(*) > 1; CONSULTA DE DUPLICADOS*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions_2.transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;	

## Observo la columna que tiene el hándicap, antes de unir products y transactions#
SELECT product_ids 
FROM transactions_2.transactions
WHERE product_ids NOT IN (SELECT id FROM products);   /*Abans de carregar la FOREIGN KEY de transactions amb products, 
s'han de separar les variablesla columna products_ids de products*/

/* Esta consulta me separa las múltiples variables (id_products) de la misma columna de transactions*
SELECT SUBSTRING_INDEX(product_ids, ',', 1)  primer_product_id FROM transactions where id = 'AB069F53-965E-A2A8-CE06-CA8C4FD92501';
SELECT SUBSTRING_INDEX(product_ids, ',', 1)  primer_product_id FROM transactions WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A05DD';
SELECT SUBSTRING_INDEX((product_ids, ',', 2), ',', -1)  segundo_product_id FROM transactions WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A05DD';
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1) AS tercer_product_id FROM transactions WHERE id = 'AB069F53-965E-A2A8-CE06-CA8C4FD92501';
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1) AS cuarto_product_id FROM transactions WHERE ID = '108B1D1D-5B23-A76C-55EF-C568E49A05DD';
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4),',', 2) AS cuarto_product_id FROM transactions WHERE ID = 'AB069F53-965E-A2A8-CE06-CA8C4FD92501';

SELECT CASE WHEN LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 2
 THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1))
        ELSE NULL
		END AS segundo_valor
FROM transactions WHERE ID = 'AB069F53-965E-A2A8-CE06-CA8C4FD92501';
/*'AB069F53-965E-A2A8-CE06-CA8C4FD92501', '11, 13, 61, 29'
'108B1D1D-5B23-A76C-55EF-C568E49A05DD','59'*/

/*El comando FIN_IN_SET tengo que probarlo, porque me serviría para encontrar esas variables, haciéndolo de otra forma.
/*FIND_IN_SET;*/  

/*Quiero hacer una tabla con las "desconcanetaciones" (=separar)*/

CREATE TABLE products_transactions 
    (id_transaction VARCHAR(255),
    product_1 VARCHAR(255),
    product_2 VARCHAR(255),
    product_3 VARCHAR(255),
    product_4 VARCHAR(255),
    PRIMARY KEY (id_transaction, product_1),
    FOREIGN KEY (product_1) REFERENCES products(id),
    FOREIGN KEY (product_2) REFERENCES products(id),
    FOREIGN KEY (product_3) REFERENCES products(id),
    FOREIGN KEY (product_4) REFERENCES products(id));

##Separar los productos separados en columnas##
INSERT INTO products_transactions (id_transaction, product_1, product_2, product_3, product_4)
SELECT id as id_transaction, 
    TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS product_1,
    CASE WHEN LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 2 
         THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 2), ',', -1)) 
         ELSE NULL END AS product_2,
    CASE WHEN LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 3 
         THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 3), ',', -1)) 
         ELSE NULL END AS product_3,
    CASE WHEN LENGTH(product_ids) - LENGTH(REPLACE(product_ids, ',', '')) + 1 >= 4 
         THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', 4), ',', -1)) 
         ELSE NULL END AS product_4
FROM transactions;

SELECT * FROM products_transactions;  ##DROP TABLE products_transactions;*/

##Transformaremos las columnas en filas, para obtener una sola columna del id de products y crearemos la tabla definitiva intermedia, 
##no borro la anterior, porque quizás la puedo usar:##

	SHOW INDEXES FROM transactions;  
    ALTER TABLE transactions ADD INDEX idx_id (id); ##Se crea el id de transactions como clave principal antes de crearla##
       
CREATE TABLE transc_prod_DEFINITIVA (
    id_transaction VARCHAR(255),
    product_id VARCHAR(10),
    FOREIGN KEY (id_transaction) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id));

INSERT INTO transc_prod_definitiva (id_transaction, product_id)
SELECT id_transaction, product_1 AS product_id FROM products_transactions
UNION ALL SELECT id_transaction, product_2 FROM products_transactions
WHERE product_2 IS NOT NULL
UNION ALL SELECT id_transaction, product_3 FROM products_transactions
WHERE product_3 IS NOT NULL
UNION ALL SELECT id_transaction, product_4 FROM products_transactions
WHERE product_4 IS NOT NULL;

SELECT * FROM transc_prod_definitiva;


/*IMPORTANT: No he volgut en aquesta ocasió a l'hora de carregar les dades a la taula USERS
nomenar la columna birth_date como DATE, 
entenent que vull saber com transformar la columna a DATE si ja tingués la taula amb les dades*/

SELECT STR_TO_DATE (birth_date, '%Y-%m-%d') AS birth_DATE FROM transactions_2.users_ca;	   ###Consulta temporal, para comparar como fecha la columna, 
##SELECT STR_TO_DATE(mi_columna, '%Y-%m-%d') AS fecha_convertida FROM mi_tabla;			    ##sin haberla convertido##

/*SELECT birth_date, STR_TO_DATE(birth_date, '%Y-%m-%d') 
FROM transactions_2.users_ca 
WHERE STR_TO_DATE(birth_date, '%Y-%m-%d') IS NULL;
La anterior consulta hace esto: 
Selecciona la columna birth_date y su conversión a DATE
sql
SELECT birth_date, STR_TO_DATE(birth_date, '%Y-%m-%d') 
FROM transactions_2.users_ca
birth_date es el valor original almacenado en la tabla transactions_2.users_ca.
STR_TO_DATE(birth_date, '%Y-%m-%d') intenta convertir birth_date al formato DATE usando el patrón '%Y-%m-%d' (Año-Mes-Día).
Filtra los valores que no se pudieron convertir a DATE
WHERE STR_TO_DATE(birth_date, '%Y-%m-%d') IS NULL;
Esto significa que solo se mostrarán los registros donde la función STR_TO_DATE() devuelve NULL.
Un valor NULL indica que el formato del dato no coincide con '%Y-%m-%d' y por lo tanto, la conversión no fue posible.*/

SELECT birth_date, STR_TO_DATE(birth_date, '%b %e, %Y') Canvi_format FROM transactions_2.users;  ##Convertir temp.column varchar a DATE si ya cargados los datos##
ALTER TABLE transactions_2.users ADD COLUMN birth_date_format DATE;  ##Crear una columna nueva##
SET SQL_SAFE_UPDATES = 0;
UPDATE transactions_2.users SET birth_date_format = STR_TO_DATE(birth_date, '%b %e, %Y');
SET SQL_SAFE_UPDATES = 1; ##Se vuelve a activar el modo seguro después##


DESC transactions_2.users;

/*Notes: 
ALTER TABLE transactions_2.users_ca DROP COLUMN birth_date_converted;  ##Esborrar columna */
/*Sep 8, 1987  Formato MySQL: (YYYY-MM-DD)
Especificadores de formato comunes que puedes utilizar con `STR_TO_DATE()`:
%d: Día del mes (01 a 31)
%m: Mes (01 a 12)
%Y: Año (cuatro dígitos)
%H: Hora (00 a 23)
%i: Minutos (de 00 a 59)
%s: Segundos (de 00 a 59)
%W: Nombre del día de la semana (por ejemplo, domingo)
%b: Nombre abreviado del mes (por ejemplo, Ene)*/
/*Les notes següents seria fer a la taula d'usuaris afegint la conversió de DATE a la creació de la taula

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE transactions_2.Users_uk_usa
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'	 ##Como es un archivo WIndows CRLF cada línea, de manera oculta, acaba en \r\n;##
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
SET
birth_date = STR_TO_DATE (@birth_date,  '%b %e, %Y');*/

##Exercici 1
##Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.##

SELECT u.id, u.name, u.surname, COUNT(t.id) nombre_transactions
FROM users u JOIN transactions t ON u.id = t.user_id
GROUP BY u.id, u.name, u.surname
HAVING COUNT(t.id) > 30;

##Nivell 2
##Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres 
##transaccions van ser declinades i genera la següent consulta: 
##Exercici 1. Quantes targetes estan actives?

CREATE TABLE Estat_targetes 
(card_id VARCHAR(50) PRIMARY KEY,
    status ENUM('Acceptada', 'Rebutjada'));
        
INSERT INTO Estat_targetes (card_id, status)
SELECT t.card_id, 
    CASE WHEN (SELECT COUNT(*) FROM transactions t2 
            WHERE t2.card_id = t.card_id 
			ORDER BY t2.timestamp DESC LIMIT 3) = 
            (SELECT COUNT(*) FROM transactions t2 
            WHERE t2.card_id = t.card_id AND t2.declined = 1
            ORDER BY t2.timestamp DESC LIMIT 3) 
	THEN 'Rebutjada'
	ELSE 'Acceptada'  ##CASE: <Primera Subconsulta> = <Segunda Subconsulta> THEN 'Rebutjada' ELSE 'Acceptada'##
    END as status
FROM transactions t
GROUP BY t.card_id;


SELECT timestamp, declined, card_id, 
RANK () over (partition by card_id order by timestamp DESC) AS ranking FROM transactions; ##WHERE ranking BETWEEN 1 and 3 GROUP BY card_id;


SELECT COUNT(*) FROM transactions t 
            WHERE t.card_id = t.card_id 
			ORDER BY t.timestamp DESC LIMIT 3;

/*La segunda consulta del CASE es similar a la primera, pero con una condición adicional: Solamente cuenta las transacciones que fueron rechazadas (declined = 1).
Si una tarjeta tiene 3 transacciones recientes y las 3 fueron rechazadas, esta subconsulta devolverá 3.
Si hubo menos de 3 transacciones o alguna fue aceptada, el valor será menor a 3.*/

SELECT * FROM transactions t2 WHERE t2.card_id = 'CdU-2938';


##Comptem les targetes##
SELECT COUNT(*) Targetes_acceptades FROM Estat_targetes
WHERE status = 'Acceptada';

##Nivell 3 
##Exercici 1 
##Necessitem conèixer el nombre de vegades que s'ha venut cada producte. 

SELECT product_id, COUNT(*) Total_vendes_cada_producte
FROM transc_prod_definitiva
GROUP BY product_id
ORDER BY Total_vendes_cada_producte DESC;










