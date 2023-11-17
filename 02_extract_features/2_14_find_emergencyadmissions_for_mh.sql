/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates a table for each mental health reason and counts yearly emergency admissions
per person per specific reason ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/


DROP TABLE if exists [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]

SELECT [X_SEQNO] as num_emadm
      ,[PSEUDO_NHS_NO]
      ,[START_DATE_HOSP_PRO_SPELL]
	  ,'self-harm' as 'reason'
	  ,1 as 'priority'
	  ,[BIRTH_DATE]
      ,[Z_SPELL_AGE]
	  ,[SEX]
      ,[ETHNIC_GROUP]
      ,[LSOA11]
      ,[LocalAuthority]
        
  INTO #temp1
  FROM [Client_ICS].[vw_SUS_APC_Actuals_DirectAccess]
  WHERE LAST_EPI_IN_SPELL_INDICAT = 1 AND YEAR(START_DATE_HOSP_PRO_SPELL)>2017 
  AND (ADMINISTRATIVE_CATEGORY = '01' OR ADMINISTRATIVE_CATEGORY = '03') 
  AND ((ad_method_hosp_prov_spell like '2%')) --- emergency admission
  AND
  (   [Diagnosis_all] like '%X60%'or [Diagnosis_all] like '%X61%'or [Diagnosis_all] like '%X62%'or [Diagnosis_all] like '%X63%'
   or [Diagnosis_all] like '%X64%'or [Diagnosis_all] like '%X65%'or [Diagnosis_all] like '%X66%'or [Diagnosis_all] like '%X67%'
   or [Diagnosis_all] like '%X68%'or [Diagnosis_all] like '%X69%'or [Diagnosis_all] like '%X70%'or [Diagnosis_all] like '%X71%'
   or [Diagnosis_all] like '%X72%'or [Diagnosis_all] like '%X73%'or [Diagnosis_all] like '%X74%'or [Diagnosis_all] like '%X75%'
   or [Diagnosis_all] like '%X76%'or [Diagnosis_all] like '%X77%'or [Diagnosis_all] like '%X78%'or [Diagnosis_all] like '%X79%'
   or [Diagnosis_all] like '%X80%'or [Diagnosis_all] like '%X81%'or [Diagnosis_all] like '%X82%'or [Diagnosis_all] like '%X83%'
   or [Diagnosis_all] like '%X84%'
  )

union

 ( SELECT [X_SEQNO] as num_emadm
      ,[PSEUDO_NHS_NO]
      ,[START_DATE_HOSP_PRO_SPELL]
	  ,'other' as 'reason'
	  ,5 as 'priority'
	  ,[BIRTH_DATE]
      ,[Z_SPELL_AGE]
	  ,[SEX]
      ,[ETHNIC_GROUP]
      ,[LSOA11]
      ,[LocalAuthority]
      
     
  FROM [Client_ICS].[vw_SUS_APC_Actuals_DirectAccess]
  WHERE LAST_EPI_IN_SPELL_INDICAT = 1 AND YEAR(START_DATE_HOSP_PRO_SPELL)>2017 
  AND (ADMINISTRATIVE_CATEGORY = '01' OR ADMINISTRATIVE_CATEGORY = '03') 
  AND ((ad_method_hosp_prov_spell like '2%')) --- emergency admission

   AND
   (  ([Diagnosis_all] like '%F2%' OR [Diagnosis_all] like '%F3%' OR [Diagnosis_all] like '%F4%' OR [Diagnosis_all] like '%F9%'
      OR [Diagnosis_all] like '%F51%' OR [Diagnosis_all] like '%F53%' )

    and [Diagnosis_all]  not like '%F0%'
	and [Diagnosis_all]  not like '%F1%'
    and [Diagnosis_all]  not like '%F50%')

  )


union

( SELECT [X_SEQNO] as num_emadm
      ,[PSEUDO_NHS_NO]
      ,[START_DATE_HOSP_PRO_SPELL]
	  ,'eating' as 'reason'
	  ,2 as 'priority'
	  ,[BIRTH_DATE]
      ,[Z_SPELL_AGE]
	  ,[SEX]
      ,[ETHNIC_GROUP]
      ,[LSOA11]
      ,[LocalAuthority]
      
  FROM [Client_ICS].[vw_SUS_APC_Actuals_DirectAccess]
  WHERE LAST_EPI_IN_SPELL_INDICAT = 1 AND YEAR(START_DATE_HOSP_PRO_SPELL)>2017 
  AND (ADMINISTRATIVE_CATEGORY = '01' OR ADMINISTRATIVE_CATEGORY = '03') 
  AND ((ad_method_hosp_prov_spell like '2%')) --- emergency admission

  AND
 (
   [Diagnosis_all] like '%F50%'
)

)

union


(  SELECT [X_SEQNO] as num_emadm
      ,[PSEUDO_NHS_NO]
      ,[START_DATE_HOSP_PRO_SPELL]
	  ,'alcohol' as 'reason'
	  ,4 as 'priority'
	  ,[BIRTH_DATE]
      ,[Z_SPELL_AGE]
	  ,[SEX]
      ,[ETHNIC_GROUP]
      ,[LSOA11]
      ,[LocalAuthority]
      
  FROM [Client_ICS].[vw_SUS_APC_Actuals_DirectAccess]
  WHERE LAST_EPI_IN_SPELL_INDICAT = 1 AND YEAR(START_DATE_HOSP_PRO_SPELL)>2017 
  AND (ADMINISTRATIVE_CATEGORY = '01' OR ADMINISTRATIVE_CATEGORY = '03') 
  AND ((ad_method_hosp_prov_spell like '2%')) --- emergency admission

  AND
 (
   [Diagnosis_all] like '%F10%'

)
)


union

(  SELECT [X_SEQNO] as num_emadm
      ,[PSEUDO_NHS_NO]
      ,[START_DATE_HOSP_PRO_SPELL]
	  ,'substance' as 'reason'
	  ,3 as 'priority'
	  ,[BIRTH_DATE]
      ,[Z_SPELL_AGE]
	  ,[SEX]
      ,[ETHNIC_GROUP]
      ,[LSOA11]
      ,[LocalAuthority]
      
  FROM [Client_ICS].[vw_SUS_APC_Actuals_DirectAccess]
  WHERE LAST_EPI_IN_SPELL_INDICAT = 1 AND YEAR(START_DATE_HOSP_PRO_SPELL)>2017 
  AND (ADMINISTRATIVE_CATEGORY = '01' OR ADMINISTRATIVE_CATEGORY = '03') 
  AND ((ad_method_hosp_prov_spell like '2%')) --- emergency admission
  AND
 (
   [Diagnosis_all] like '%F11%'
or [Diagnosis_all] like '%F12%'
or [Diagnosis_all] like '%F13%'
or [Diagnosis_all] like '%F14%'
or [Diagnosis_all] like '%F15%'
or [Diagnosis_all] like '%F16%'
or [Diagnosis_all] like '%F17%'
or [Diagnosis_all] like '%F18%'
or [Diagnosis_all] like '%F19%'
)

)




SELECT [X_SEQNO] as num_emadm
      ,min([PSEUDO_NHS_NO])
      ,min([START_DATE_HOSP_PRO_SPELL]) as 'EventDate'
	  ,CASE 
	   WHEN min('priority')= 1 THEN 'self-harm'
       WHEN min('priority')= 2 THEN 'eating'
	   WHEN min('priority')= 3 THEN 'substance'
	   WHEN min('priority')= 4 THEN 'alcohol'
	   ELSE 'other' END as 'diagnosis'
	  ,min([BIRTH_DATE])
      ,min([Z_SPELL_AGE])
	  ,min([SEX])
      ,min([ETHNIC_GROUP])
      ,min([LSOA11])
      ,min([LocalAuthority])
        
  INTO [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions] 
  FROM #temp1
  GROUP BY X_SEQNO