## NIVELL 1 SPRINT 2##

## ## Exercici 1. A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues
## taules. Mostra les característiques principals de l'esquema creat i explica les diferents
## taules i variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació
## entre les diferents taules i variables.

SELECT * FROM company;
SELECT * FROM transaction;

##Exercici 2.  Utilitzant JOIN realitzaràs les següents consultes:
	##Llistat dels països que estan fent compres.
	##Des de quants països es realitzen les compres.
	##Identifica la companyia amb la mitjana més gran de vendes.

SELECT distinct country
FROM company c INNER JOIN transaction tr ON c.id = tr.company_id;

SELECT COUNT(DISTINCT c.country) as num_països
FROM company as c 
INNER JOIN transaction as tr ON c.id = tr.company_id;

SELECT c.company_name, round(AVG(tr.amount),2) AS mitjana_vendes
FROM company AS c
INNER JOIN transaction AS tr ON c.id = tr.company_id
WHERE declined = 0
GROUP BY c.company_name
ORDER BY mitjana_vendes DESC LIMIT 1;

##Exercici 3- Utilitzant només subconsultes (sense utilitzar JOIN):
## Mostra totes les transaccions realitzades per empreses d'Alemanya.
##Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
##Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

## PROVA ##
# SELECT * 
# FROM company AS c INNER JOIN transaction AS tr ON c.id = tr.company_id
# WHERE c.country = "Germany";

##SENSE JOIN: 
SELECT id, company_id, amount FROM transaction 
WHERE company_id IN (SELECT id FROM company WHERE country = "Germany");

SELECT distinct company_id FROM transaction 
WHERE amount > (SELECT AVG(amount) FROM transaction);

SELECT distinct company_name FROM company 
WHERE id IN (SELECT distinct company_id FROM transaction 
WHERE amount > (SELECT AVG(amount) FROM transaction))
ORDER BY company_name;

SELECT distinct company_name as Sense_activitat FROM company 
WHERE id NOT IN (SELECT company_id FROM transaction);      ### No hi ha cap empresa sense transaccions ### NOT EXISTS

## NIVELL 2 SPRINT 2##
####Exercici 1. Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
## Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT * FROM company;   SELECT * FROM transaction;

## PROVA ##
## SELECT company_id, timestamp, sum(amount) as suma_ingressos FROM transaction
## GROUP BY company_id, timestamp
## ORDER BY suma_ingressos DESC LIMIT 5;

## RESPOSTA CORRECTA ##
SELECT DATE(timestamp) as dia, SUM(amount) AS suma_ingressos 
FROM transaction       
WHERE declined = 0
GROUP BY dia
ORDER BY suma_ingressos DESC LIMIT 5;

## Exercici 2 Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country, round(avg(tr.amount),2) AS mitjana_vendes
FROM transaction tr JOIN company c ON tr.company_id = c.id
WHERE declined = 0
GROUP BY c.country
ORDER BY mitjana_vendes DESC;

##Exercici 3. En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a 
## fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades
## per empreses que estan situades en el mateix país que aquesta companyia.
## Mostra el llistat aplicant JOIN i subconsultes. 

SELECT tr.id, tr.amount, c.company_name,  c.country FROM transaction tr JOIN company c ON tr.company_id = c.id
WHERE c.country IN (SELECT c.country FROM company c
WHERE c.company_name = "Non Institute") and c.company_name != "Non Institute";

## Mostra el llistat aplicant solament subconsultes.

SELECT transaction.id FROM transaction 
WHERE company_id IN (SELECT id FROM company WHERE country = (SELECT country FROM company WHERE company_name = 'Non Institute') and company_name = "Non Institute"); 

/*SELECT transaction.id FROM transaction 
WHERE company_id IN (SELECT id FROM company WHERE country = (SELECT country FROM company 
        WHERE company_name = 'Non Institute')) 
and company_id != (SELECT id FROM company WHERE company_name = "Non Institute"); */
	
## NIVELL 3 SPRINT 2##
####Exercici 1. Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions
##amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021
## i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, DATE(tr.timestamp) Fecha, tr.amount 
FROM company c JOIN transaction tr ON tr.company_id = c.id
where amount between 100 and 200 AND DATE(tr.timestamp) IN ("2021-04_29", "2021-07-20", "2022_03_13")
ORDER BY amount;

####Exercici 2. Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que
##es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions
##que realitzen les empreses, però el departament de recursos humans és exigent i vol un
##llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

/*PROVA
SELECT c.company_name, count(tr.id) as Quantitat_transaccions 
FROM company c JOIN transaction tr ON tr.company_id = c.id 
GROUP BY c.company_name;*/

##RESPOSTA CORRECTA
SELECT c.company_name,
CASE WHEN COUNT(tr.id) > 4 THEN 'Més de 4 transaccions'	ELSE '4 transaccions o menys'
	 END as Classificació 
FROM company c JOIN transaction tr ON tr.company_id = c.id
GROUP BY c.company_name
ORDER BY Classificació;




