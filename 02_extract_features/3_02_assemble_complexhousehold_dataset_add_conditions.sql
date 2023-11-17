/****** This is scripts adds some more conditions from the conditions table
these are important for the kind of analysis of complex households since it is
about children and families. This is an example of how to add other variables of interest
from the conditions table - in this case [RP102_Conditions]
******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/



DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_2]

SELECT P.*
      
	   ,(CASE WHEN C.[Attention_Deficit_Hyperactivity_Disorder_MAX]
	    is not null THEN 1 ELSE 0 END +
        CASE WHEN C.[AUTISM_MAX]
		is not null THEN 1 ELSE 0 END) as 'neurodevelopmental'
     
  
INTO  [Client_SystemP_RW].[RP007_SPHD_2] 
FROM  [Client_SystemP_RW].[RP007_SPHD_1] P


INNER JOIN [Client_SystemP_RW].[RP102_Conditions] C
ON P.[Pseudo_NHS_Number] = C.[Pseudo_NHS_Number]  
  

