/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to count antidepressant prescriptions for a given year ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

DECLARE @specificYear INT;
SET @specificYear = 2021


DROP TABLE if exists Client_SystemP_RW.RP_ADprescriptions_2021
SELECT  Pseudo_NHS_Number,
     COUNT(*) AS "Antidepressants"
	 INTO Client_SystemP_RW.RP_ADprescriptions_2021
     FROM Client_SystemP_RW.RP201_ADprescriptions
     WHERE YEAR(MedicationDate) = @specificYear
    
GROUP BY	
Pseudo_NHS_Number 
                     
