/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to search the additional tables
in ECDS which report drug- and alcohol-related injury -
does not use restructured for system p data model ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/



drop table if exists [Client_SystemP_RW].[RP_ECDS_AlcoholDrugInvolvment_v2]


SELECT  sus.[EC_Ident], 
          sus.[CMv2_Pseudo_Number]
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
		 ,e.EC_Alcohol_Drug_Involvement_01

		 INTO [Client_SystemP_RW].[RP_ECDS_AlcoholDrugInvolvment_v2] 
  FROM [Client_ICS].[vw_SUS_Faster_ECDS] sus
  


  LEFT JOIN [Client_ICS].[vw_SUS_Faster_ECDS_AlcoholDrugInvolvement] e
  ON sus.EC_Ident = e.EC_Ident