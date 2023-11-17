/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to find alcohol abuse episodes -
does not use restructured for system p data model ******/
/*** Method originally by Lee Kirkham, cfr. NDL phase 1- topic 2 ***/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/


DROP TABLE if exists Client_SystemP_RW.RP_ref_SNOMED_Alcohol
DROP TABLE if exists [Client_SystemP_RW].RP_AEAttendances_alcohol --added final table here

SELECT [ID]
      ,[Active]
      ,[Module_ID]
      ,[Concept_ID]
      ,[Language_Code]
      ,[Type_ID]
      ,[Term]
      ,[Case_Significance_ID]
      ,[Source_File]
      ,[In_Source_Data]
      ,[Import_Date]
      ,[Created_Date]
      ,[Is_Latest]
      ,[Effective_From]
      ,[Effective_To]
      ,[PK_NonStaticID]
         INTO Client_SystemP_RW.RP_ref_SNOMED_Alcohol
  FROM [UKHD_REF].[SNOMED_Descriptions_SCD] ref
  
  inner join 
  (
  Select Concept_ID as CI,max([PK_NonStaticID]) MxNSI
  from [UKHD_REF].[SNOMED_Descriptions_SCD] where 
  (Term like '%alcohol%' AND Term like '%disorder%') OR
  (Term like '%alcohol%' AND Term like '%injury%')
  group by Concept_ID
  ) findTerm on 
  findTerm.CI = ref.[Concept_ID] and
  findterm.MxNSI =ref.PK_NonStaticID


/*** USE THESE CODES TO FIND AE ATTENDANCES WHERE ALCOHOL WAS INVOLVED ***/

SELECT 
       sus.[EC_Ident]
         ,sus.[CMv2_Pseudo_Number]
      ,sus.[EC_PCD_Indicator]
      ,sus.[Generated_Record_ID]
      ,sus.[EC_Chief_Complaint_SNOMED_CT]   
      ,sus.[Der_EC_Diagnosis_All]   
         ,sus.[Der_EC_Arrival_Date_Time]
         ,diag.EC_Chief_Complaint_SNOMED_CT diagChief
         ,SnomedRef.Term as Chief_Term
         ,diag.EC_Diagnosis_01
         ,SnomedRef1.Term as Diag1_term
         ,diag.EC_Diagnosis_02
         ,SnomedRef2.Term as Diag2_term

INTO [Client_SystemP_RW].RP_AEAttendances_alcohol
FROM [Client_ICS].[vw_SUS_ECDS] sus

left outer join [Client_ICS].[vw_SUS_ECDS_Diagnosis] diag on 
sus.EC_Ident = diag.EC_Ident --and
--sus.Generated_Record_ID = diag.Generated_Record_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Alcohol as SnomedRef on  --changed table
diag.EC_Chief_Complaint_SNOMED_CT = SnomedRef.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Alcohol as SnomedRef1 on --changed table
diag.EC_Diagnosis_01 = SnomedRef1.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Alcohol as SnomedRef2 on --changed table
diag.EC_Diagnosis_02 = SnomedRef2.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Alcohol as SnomedRef3 on --changed table
diag.EC_Diagnosis_03 = SnomedRef3.Concept_ID

where 
not SnomedRef.Concept_ID is null or
not SnomedRef1.Concept_ID is null  or 
not SnomedRef2.Concept_ID is null or
not SnomedRef3.Concept_ID is null
