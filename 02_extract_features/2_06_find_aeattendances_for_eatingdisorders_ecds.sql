/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to find eating disorder episodes -
does not use restructured for system p data model ******/
/*** Method originally by Lee Kirkham, cfr. NDL phase 1- topic 2 ***/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

DROP TABLE if exists Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3
DROP TABLE if exists [Client_SystemP_RW].RP_AEAttendances_eatingdisorder_v2 --added final table here

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
         INTO Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3
  FROM [UKHD_REF].[SNOMED_Descriptions_SCD] ref
  
  inner join 
  (
  Select Concept_ID as CI,max([PK_NonStaticID]) MxNSI
  from [UKHD_REF].[SNOMED_Descriptions_SCD] 
   WHERE ((Term like '%anorexia%') OR (Term like '% eating%disorder%') OR (Term like 'eating%disorder%') OR (Term like '%bulimia%'))
  AND (Term not like '%poisoning%by%eating%')
  AND (Term not like '%test%')
  AND (Term not like 'toxic effect from eating %')
  AND (Term not like 'referral %')
  AND (Term not like '% clinic')
  AND (Term not like '% survey %')
  AND (Term not like 'counseling %')
   AND (Term not like 'counselling %')
  AND (Term not like '% instrument')
  AND (Term not like '% (procedure)')
  AND (Term not like '% history %')
  AND (Term not like 'history %')
  AND (Term not like '% therapy %')
  AND (Term not like '% remission')
  AND (Term not like '% in % remission %')
  AND (Term not like '% in % remission (disorder)')
  AND (Term not like '% in remission (disorder)')
  AND (Term not like 'Diabulimia')
  AND (Term not like '%diabetes mellitus %')
  AND (Term not like '% score')
  AND (Term not like '% score (observable entity)')
  AND (Term not like 'signposting %')
  AND (Term not like '% service')
  AND (Term not like '% services')
  AND (Term not like 'Referral %')
  AND (Term not like '% Assessment %')
  AND (Term not like 'Assessment %')
  AND (Term not like '% questionnaire')
  AND (Term not like '% questionnaire%')
  AND (Term not like '% (assessment)')
  AND (Term not like '% inventory')
  AND (Term not like '% scale')
  AND (Term not like '% scale)')
  AND (Term not like '% examination')
  AND (Term not like 'dietary %')
  AND (Term not like '% dietary %')
  AND (Term not like 'seen in eating disorder clinic %')
  AND (Term not like 'seen in eating disorder clinic') 
  group by Concept_ID
  ) findTerm on 
  findTerm.CI = ref.[Concept_ID] and
  findterm.MxNSI =ref.PK_NonStaticID


/*** USE THESE CODES TO FIND AE ATTENDANCES WHERE ALCOHOL WAS INVOLVED ***/

SELECT 
       sus.[EC_Ident]
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
         ,diag.EC_Chief_Complaint_SNOMED_CT diagChief
         ,SnomedRef.Term as Chief_Term
         ,diag.EC_Diagnosis_01
         ,SnomedRef1.Term as Diag1_term
         ,diag.EC_Diagnosis_02
         ,SnomedRef2.Term as Diag2_term
		 ,diag.EC_Diagnosis_03
         ,SnomedRef3.Term as Diag3_term
INTO [Client_SystemP_RW].RP_AEAttendances_eatingdisorder_v2
FROM [Client_ICS].[vw_SUS_Faster_ECDS] sus

left outer join [Client_ICS].[vw_SUS_Faster_ECDS_Diagnosis] diag on 
sus.EC_Ident = diag.EC_Ident --and
--sus.Generated_Record_ID = diag.Generated_Record_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3 as SnomedRef on  --changed table
diag.EC_Chief_Complaint_SNOMED_CT = SnomedRef.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3 as SnomedRef1 on --changed table
diag.EC_Diagnosis_01 = SnomedRef1.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3 as SnomedRef2 on --changed table
diag.EC_Diagnosis_02 = SnomedRef2.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_EatingDisorder_v3 as SnomedRef3 on --changed table
diag.EC_Diagnosis_03 = SnomedRef3.Concept_ID

where 
not SnomedRef.Concept_ID is null or
not SnomedRef1.Concept_ID is null  or 
not SnomedRef2.Concept_ID is null or
not SnomedRef3.Concept_ID is null
