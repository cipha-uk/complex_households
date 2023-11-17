/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to serch the intent field for self-inflicted injury -
does not use restructured for system p data model ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/



DROP TABLE if exists Client_SystemP_RW.RP_ECDS_SelfHarmIntent_v2

 SELECT  sus.[EC_Ident]
         ,sus.[CMv2_Pseudo_Number]
		 ,sus.[Age_at_CDS_Activity_Date]
		 ,sus.[Der_Postcode_LSOA_Code]
		 ,sus.[Sex]
		 ,sus.[Der_Dupe_Flag]
      ,sus.[Ethnic_Category_2021]
      ,sus.[EC_PCD_Indicator]
      ,sus.[Generated_Record_ID]
      ,sus.[EC_Chief_Complaint_SNOMED_CT]   
      ,sus.[Der_EC_Diagnosis_All]   
         ,sus.[Der_EC_Arrival_Date_Time]
         
		 ,sus.EC_Injury_Intent_SNOMED_CT
  INTO Client_SystemP_RW.RP_ECDS_SelfHarmIntent_v2
  FROM [Client_ICS].[vw_SUS_Faster_ECDS] sus
  WHERE EC_Injury_Intent_SNOMED_CT = '276853009' AND Der_Dupe_Flag = 0
