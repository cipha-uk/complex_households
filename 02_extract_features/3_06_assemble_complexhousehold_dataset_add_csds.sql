/****** This is scripts adds more of the event features:
yearly
usage of several community health services form CSDS: referrals and contacts

******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/

DROP TABLE if exists [Client_SystemP_RW].[RP008_SPUP_2018_6]

SELECT P.*
	  ,CS.*   
		  
INTO  [Client_SystemP_RW].[RP008_SPUP_2018_6] 
FROM  [Client_SystemP_RW].[RP008_SPUP_2018_5] P

LEFT JOIN [Client_SystemP_RW].[RP_CSDS_Referrals_CareContacts_2021] CS
ON P.[Pseudo_NHS_Number] = CS.[CMv2_Pseudo_Number]



 
      
  