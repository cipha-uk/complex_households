/****** This is scripts adds more of the event features:
yearly
usage of several mental health services form MHSDS: referrals, contacts and reasons for referral

******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/
DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_5]

SELECT P.*
      ,MH_AE1.*
	       
		  
INTO  [Client_SystemP_RW].[RP007_SPHD_5] 
FROM  [Client_SystemP_RW].[RP007_SPHD_4] P

LEFT JOIN [Client_SystemP_RW].[RP_MHSDS_Referrals_reasons_carecontacts_2021] MH_AE1
ON P.[Pseudo_NHS_Number] = MH_AE1.[CM_PSEUDONYM]



 
      
  