USE transactions;

/* Nivell 1
- Exercici 1
La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat 
"dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.*/

Select * FROM transaction;

## CREATE INDEX credit_card_index ON transaction (credit_card_id);##Proves

CREATE TABLE IF NOT EXISTS credit_card (
  id varchar (50) primary key NOT NULL,
  iban varchar(255),
  pan VARCHAR (20),
  pin VARCHAR  (10),
  cvv VARCHAR (10),		## Comentar que no es INT por si empieza por 0*/
  expiring_date varchar (12));
  
ALTER TABLE transaction ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card (id);

SHOW CREATE TABLE credit_card;  
SELECT * FROM credit_card;
/*'credit_card', 'CREATE TABLE `credit_card` (\n  `id` varchar(50) NOT NULL,\n  `iban` varchar(50) DEFAULT NULL,\n  
`pin` varchar(4) DEFAULT NULL,\n  `cvv` int DEFAULT NULL,\n  `expiring_date` varchar(12) DEFAULT NULL,\n  
`fecha_actual` date DEFAULT NULL,\n  PRIMARY KEY (`id`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'*/

  
/*mysql tiene la variable “secure_file_priv” en su motor y se usa con el fin de limitar las operaciones de carga y descarga de datos.
Por lo cual debemos buscar la ruta de esa variable para allí alojar el archivo que queremos cargar, 
EN EL CASO DE QUE NO FUERA UN ARCHIVO SQL COMO EN ESTA CASO por lo cual debemos hacer lo siguiente:*/

SHOW VARIABLES LIKE "secure_file_priv";

##C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\

/* Nivell 1 SPRINT 2
- Exercici 2
El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de mostrar-se 
per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.*/

##ALTER TABLE credit_card change      R323456312213576817699999 SMALLINT NOT NULL;  ## CAMBIA TODA LA FILA,  NO SIRVE

update credit_card set iban = "R323456312213576817699999" where id = "CcU-2938";

SELECT * FROM credit_card where id = "CcU-2938";

/* Nivell 1 SPRINT 2
- Exercici 3
En la taula "transaction" ingressa un nou usuari amb la següent informació:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999  
lat	829.999
longitude	-117.999
amount	111.11
declined	0*/

SELECT * FROM transaction; SELECT * FROM company; SELECT * FROM credit_card;  
SELECT * FROM company WHERE id = 'b-9999';
INSERT INTO company (id, company_name) VALUES ('b-9999', 'Empresa creada en ejercicio 3 Sprint3 N1');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO transaction (Id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 82.9999, -117.999, 111.11, 0);

SELECT * FROM transaction WHERE company_id = 'b-9999';

/* Nivell 1 SPRINT 2
- Exercici 4
Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.*/

ALTER TABLE credit_card DROP COLUMN pan;

/* Nivell 2 SPRINT 2
Exercici 1
Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.*/

DELETE FROM transaction WHERE Id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';
SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

/* Nivell 2 SPRINT 2
Exercici 2
La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
 S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
 Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
 Nom de la companyia.  Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
 Presenta la vista creada,  ordenant les dades de major a menor mitjana de compra.*/
 
SELECT * FROM transaction; SELECT * FROM company; SELECT * FROM credit_card;

CREATE  VIEW VistaMarketing as
SELECT c.company_name, c.phone, c.country, ROUND(AVG(tr.amount),2) Mitjana_compres
FROM company c 
INNER JOIN transaction tr ON c.id = tr.company_id
WHERE declined = 0
GROUP BY c.company_name, c.phone, c.country
ORDER BY Mitjana_compres ASC;

SELECT * FROM VistaMarketing;

/* Nivell 2 SPRINT 2
Exercici 3
Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"*/

SELECT * FROM VistaMarketing
WHERE country like "Germany" ;

/* Nivell 3 SPRINT 2
Exercici 1
La setmana vinent tindràs una nova reunió amb els gerents de màrqueting.
 Un company del teu equip va realitzar modificacions en la base de dades, 
 però no recorda com les va realitzar. Et demana que l'ajudis a deixar els 
 comandos executats per a obtenir el següent diagrama:*/
 
CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255),
        FOREIGN KEY(id) REFERENCES transaction(user_id));
        
INSERT INTO user (id) VALUES ('9999');
SELECT * FROM user;

        
ALTER TABLE `transactions`.`transaction`   ### CORRECTA
ADD CONSTRAINT `Transaction_ibfk_3`
FOREIGN KEY (`user_id`)
REFERENCES `transactions`.`user` (`id`)
ON DELETE RESTRICT
ON UPDATE RESTRICT;			## SET foreign_key_checks = 1 ó 0; (0 para quitar permisos, y 1 para reactivarlos)

ALTER TABLE `transactions`.`user` ADD PRIMARY KEY (`id`);
  
ALTER TABLE company DROP COLUMN website;
ALTER TABLE user RENAME data_user;
ALTER TABLE credit_card ADD fecha_actual DATE;     ## DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP; (Se está pidiendo que no sea nulo, que cada vez que añada un registro, si no tiene fecha que ponga la fecha de cuando se introduce ese registro*/
ALTER TABLE data_user RENAME COLUMN email to personal_email;
/*ALTER TABLE credit_card CHANGE iban iban VARCHAR (50);   ### SERVEIX PERÒ MÉS CORRECTA LA SEGÜENT: Canviar Varchar a 250##*/
ALTER TABLE credit_card MODIFY COLUMN iban VARCHAR (50);  ### CORRECTA: Canviar Varchar a 250##
    
/* Nivell 3 SPRINT 2
Exercici 2
L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

ID de la transacció
Nom de l'usuari/ària
Cognom de l'usuari/ària
IBAN de la targeta de crèdit usada.
Nom de la companyia de la transacció realitzada.
Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction. */
   
SELECT * FROM transaction; SELECT * FROM company; SELECT * FROM credit_card; SELECT * FROM data_user;  
 
CREATE  VIEW InformeTecnico as 
SELECT tr.id ID_TRANSACCIÓ, u.name NOM_CLIENT, u.surname COOGNOM_CLIENT, crd.iban IBAN, c.company_name BANC
FROM company c 
JOIN transaction tr ON c.id = tr.company_id 
JOIN credit_card crd ON tr.credit_card_id = crd.id
JOIN data_user u ON u.id = tr.user_id
ORDER BY ID_TRANSACCIÓ DESC;

SELECT * FROM InformeTecnico;
SHOW CREATE TABLE InformeTecnico;
DROP VIEW InformeTecnico; 









  
    








