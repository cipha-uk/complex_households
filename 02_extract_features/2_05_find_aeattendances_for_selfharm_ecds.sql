/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to find which snomed codes refer to self harm events and then use 
these codes to look into the diagnoses fields of [vw_SUS_Faster_ECDS] to find self-harm episodes -
does not use restructured for system p data model ******/
/*** Method originally by Lee Kirkham, cfr. NDL phase 1- topic 2 ***/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

/*
-------------------------------------------------------------------------------------------------------------
This software is released under the GNU GENERAL PUBLIC license. See the LICENSE file for details.

THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. 

IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You acknowledge and agree that the use of this software is at your own risk, and the authors disclaim 
any and all liability for any direct, indirect, incidental, consequential, or special damages or losses 
that may result from the use or inability to use the software.
-------------------------------------------------------------------------------------------------------------
*/


DROP TABLE if exists Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3
DROP TABLE if exists [Client_SystemP_RW].RP_AEAttendances_selfharm_v3 --added final table here

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
         INTO Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3
  FROM [UKHD_REF].[SNOMED_Descriptions_SCD] ref
  
  inner join 
  (
  Select Concept_ID as CI,max([PK_NonStaticID]) MxNSI
  from [UKHD_REF].[SNOMED_Descriptions_SCD]  
  WHERE ((Term like '%self%harm%') OR (Term like '%self%injur%') OR (Term like '%suicid%'))
  AND (Term not like '%no%thoughts%') 
  AND (Term not like '%history%')
  AND (Term not like '%adherent%')
  AND (Term not like '%relative%')
  AND (Term not like '%H/O%')
  AND (Term not like '%FH%')
  AND (Term not like '%assessment%')
  AND (Term not like '%scale%')
  AND (Term not like '%low%risk%')
  AND (Term not like '%unknown%risk%')
  AND (Term not like '%bereavement%')
  AND (Term not like '%psychotherapy%')
  AND (Concept_ID <> 158062004) 
  AND (Concept_ID <> 223318002) 
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
INTO [Client_SystemP_RW].RP_AEAttendances_selfharm_v3
FROM [Client_ICS].[vw_SUS_Faster_ECDS] sus

left outer join [Client_ICS].[vw_SUS_Faster_ECDS_Diagnosis] diag on 
sus.EC_Ident = diag.EC_Ident --and
--sus.Generated_Record_ID = diag.Generated_Record_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3 as SnomedRef on  --changed table
diag.EC_Chief_Complaint_SNOMED_CT = SnomedRef.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3 as SnomedRef1 on --changed table
diag.EC_Diagnosis_01 = SnomedRef1.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3 as SnomedRef2 on --changed table
diag.EC_Diagnosis_02 = SnomedRef2.Concept_ID

left outer join Client_SystemP_RW.RP_ref_SNOMED_Self_Harm_v3 as SnomedRef3 on --changed table
diag.EC_Diagnosis_03 = SnomedRef3.Concept_ID

where 
not SnomedRef.Concept_ID is null or
not SnomedRef1.Concept_ID is null  or 
not SnomedRef2.Concept_ID is null or
not SnomedRef3.Concept_ID is null
