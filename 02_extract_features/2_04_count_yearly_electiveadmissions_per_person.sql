/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to count yearly Elective Admissions uses APCS data
restructured for system p data model ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

DECLARE @specificYear INT;
SET @specificYear = 2021

DROP TABLE if exists Client_SystemP_RW.RP_ElectiveAdmissions_2021


SELECT CM_PSEUDONYM as 'Pseudo_NHS_Number'
      ,count(*) as ElectiveAdmissions12
      ,sum(COST) as ElAdmCost	  
  INTO Client_SystemP_RW.RP_ElectiveAdmissions_2021
  FROM Client_SystemP_RW.KD_SUS_APCS_OMOP
  WHERE YEAR(EVENT_DATE) = @specificYear AND (SERVICE = '3') AND EVENT_TYPE = '2' AND CM_PSEUDONYM is not null
  GROUP BY CM_PSEUDONYM
  