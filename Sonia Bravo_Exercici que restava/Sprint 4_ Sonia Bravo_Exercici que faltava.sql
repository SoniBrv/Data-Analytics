##Nivell 1 
##Exercici 2 
##Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules. 

SELECT c.company_name, t.id, ROUND(AVG(t.amount),2)
FROM transactions t JOIN companies c ON t.business_id = c.company_id 
WHERE c.company_name = 'Donec Ltd'
GROUP BY c.company_name, t.id;


