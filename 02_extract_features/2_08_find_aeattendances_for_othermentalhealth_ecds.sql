/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to find other mental health episodes (mostly severe mental illness) -
does not use restructured for system p data model ******/
/*** Method originally by Lee Kirkham, cfr. NDL phase 1- topic 2 ***/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

DROP TABLE if exists Client_SystemP_RW.RP_ref_SNOMED_smi_v3
DROP TABLE if exists [Client_SystemP_RW].RP_AEAttendances_smi_v2 --added final table here

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
         INTO Client_SystemP_RW.RP_ref_SNOMED_smi_v3
  FROM [UKHD_REF].[SNOMED_Descriptions_SCD] ref
  
  inner join 
  (
  Select Concept_ID as CI,max([PK_NonStaticID]) MxNSI
  from [UKHD_REF].[SNOMED_Descriptions_SCD] 
 WHERE (Term like '%bipolar%disorder%' OR  Term like '%schizophreni%disorder' OR Term like '%psychosis%disorder' OR Term like '%psychotic%disorder'  OR Term like '%bipolar%finding%' OR  Term like '%schizophreni%finding' OR Term like '%psychotic%finding') 
  AND (Term not like '%score%')
  AND (Term not like '%scale%') AND (Term not like '%ssessment%') AND (Term not like '%rocedure%')
  AND (Term not like '%uestionnaire%') AND (Term not like '%resolved%') 
  AND (Term not like '%declined%') 
  And (Term not like '% symptom%')
  And (Term not like '%referral %')
  And (Term not like '% intervention %')
  And (Term not like '% full dose %')
  And (Term not like '% service %')
  And (Term not like '% register %')
  And (Term not like '% review %')
  And (Term not like '% quality indicator%') 
  And (Term not like '% register %')
  And (Term not like '% screen %')
  And (Term not like '% review %') 
  And (Term not like '% therapy %')
  And (Term not like '% remission %')
  And (Term not like '% remission')
  And (Term not like '%history %') 
  And (Term not like '%family %')
  And (Term not like '%h/o %') 
  And (Term not like '%f/h %')
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

INTO [Client_SystemP_RW].RP_AEAttendances_smi_v2
FROM [Client_ICS].[vw_SUS_Faster_ECDS] sus

left outer join [Client_ICS].[vw_SUS_Faster_ECDS_Diagnosis] diag on 
sus.EC_Ident = diag.EC_Ident --and
--sus.Generated_Record_ID = diag.Generated_Record_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_smi_v3 as SnomedRef on  --changed table
diag.EC_Chief_Complaint_SNOMED_CT = SnomedRef.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_smi_v3 as SnomedRef1 on --changed table
diag.EC_Diagnosis_01 = SnomedRef1.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_smi_v3 as SnomedRef2 on --changed table
diag.EC_Diagnosis_02 = SnomedRef2.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_smi_v3 as SnomedRef3 on --changed table
diag.EC_Diagnosis_03 = SnomedRef3.Concept_ID

where 
not SnomedRef.Concept_ID is null or
not SnomedRef1.Concept_ID is null  or 
not SnomedRef2.Concept_ID is null or
not SnomedRef3.Concept_ID is null
