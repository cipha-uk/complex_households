/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates takes the yearly summaries of activity from the system p data model for
MHSDS [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2021] which contain monthly counts
and from [Client_SystemP_RW].[KD_MHSDS_OMOP_Referral] which contain single events 
- the monthly counts are summed into yearly counts and the codes corresponding to service types/teams
are recoded with words 
- the single events are also extracted, regrouped and recoded to make summaries for the reasons for referrals
- then they are put together

******/

/***TO DO at some stage the name of the field corresponding to the CM pseudonym changed and I still
need to check all code for it****/

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

DROP TABLE if exists [Client_SystemP_RW].[RP_MHSDS_Referrals_test2]
DROP TABLE if exists [Client_SystemP_RW].[RP_MHSDS_Referrals_CareContacts_2021]
DROP TABLE if exists [RP_MHSDS_Referrals_reasons_carecontacts_2021]

SELECT [CMv2_Pseudo_Number]
      ,sum([Ref_Total]) as 'mh_referrals_tot_12'
      ,sum([R_SType01]) as 'ref_service_asylum_12'
      ,sum([R_SType02]) as 'ref_service_autism_12'
      ,sum([R_SType03]) as 'ref_service_community_12'
      ,sum([R_SType04]) as 'ref_service_community_org_12'
      ,sum([R_SType05]) as 'ref_service_crisis_12'
      ,sum([R_SType06]) as 'ref_service_eating_12'
      ,sum([R_SType07]) as 'ref_service_education_12'
      ,sum([R_SType08]) as 'ref_service_gambling_12'
      ,sum([R_SType09]) as 'ref_service_gen_psychiatry_12'
      ,sum([R_SType10]) as 'ref_service_judicial_12'
      ,sum([R_SType11]) as 'ref_service_lac_12'
      ,sum([R_SType12]) as 'ref_service_learning_neurodevelop_12'
      ,sum([R_SType13]) as 'ref_service_learning_forensic_12'
      ,sum([R_SType14]) as 'ref_service_liaison_12'
      ,sum([R_SType15]) as 'ref_service_neurodevelopment_12'
      ,sum([R_SType16]) as 'ref_service_other_12'
      ,sum([R_SType17]) as 'ref_service_perinatalparenting_12'
      ,sum([R_SType18]) as 'ref_service_personality_12'
      ,sum([R_SType19]) as 'ref_service_primary_care_12'
      ,sum([R_SType20]) as 'ref_service_psychological_noniapt_12'
      ,sum([R_SType21]) as 'ref_service_psychosis_early_12'
      ,sum([R_SType22]) as 'ref_service_roughsleeping_12'
      ,sum([R_SType23]) as 'ref_service_severe_12'
      ,sum([R_SType24]) as 'ref_service_sp_access_12'
      ,sum([R_SType25]) as 'ref_service_substance_12'
      ,sum([R_SType26]) as 'ref_service_youth_offend_12'
      ,sum([R_SType98]) as 'ref_service_unknown_12'
      ,sum([Cont_Total]) as 'mh_contacts_tot_12'
      ,sum([C_SType01]) as 'cont_service_asylum_12'
      ,sum([C_SType02]) as 'cont_service_autism_12'
      ,sum([C_SType03]) as 'cont_service_community_12'
      ,sum([C_SType04]) as 'cont_service_community_org_12'
      ,sum([C_SType05]) as 'cont_service_crisis_12'
      ,sum([C_SType06]) as 'cont_service_eating_12'
      ,sum([C_SType07]) as 'cont_service_education_12'
      ,sum([C_SType08]) as 'cont_service_gambling_12'
      ,sum([C_SType09]) as 'cont_service_gen_psychiatry_12'
      ,sum([C_SType10]) as 'cont_service_judicial_12'
      ,sum([C_SType11]) as 'cont_service_lac_12'
      ,sum([C_SType12]) as 'cont_service_learning_neurodevelop_12'
      ,sum([C_SType13]) as 'cont_service_learning_forensic_12'
      ,sum([C_SType14]) as 'cont_service_liaison_12'
      ,sum([C_SType15]) as 'cont_service_neurodevelopment_12'
      ,sum([C_SType16]) as 'cont_other_12'
      ,sum([C_SType17]) as 'cont_service_perinatalparenting_12'
      ,sum([C_SType18]) as 'cont_service_personality_12'
      ,sum([C_SType19]) as 'cont_service_primary_care_12'
      ,sum([C_SType20]) as 'cont_service_psychological_noniapt_12'
      ,sum([C_SType21]) as 'cont_service_psychosis_early_12'
      ,sum([C_SType22]) as 'cont_service_roughsleeping_12'
      ,sum([C_SType23]) as 'cont_service_severe_12'
      ,sum([C_SType24]) as 'cont_service_sp_access_12'
      ,sum([C_SType25]) as 'cont_service_substance_12'
      ,sum([C_SType26]) as 'cont_service_youth_offend_12'
      ,sum([C_SType98]) as 'cont_service_unknown_12'
      
  INTO [Client_SystemP_RW].[RP_MHSDS_Referrals_CareContacts_2021]
  FROM [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2021]
  GROUP BY (CMv2_Pseudo_Number)




/*** here get the events for a particular year and recode and regroup them with words rather than numeric ids   ***/
SELECT TBl.[CM_PSEUDONYM]
       ,Tbl.[EVENT_DATE]
	   ,Tbl.[EVENT_REASON]
       , case
	         when EVENT_REASON='25' or EVENT_REASON='25' then 'autism'
			 when EVENT_REASON='16' or EVENT_REASON='17' or EVENT_REASON='24' or EVENT_REASON='30' then 'neurodevelopmental'
			 when EVENT_REASON='04' then 'depression'
			 when EVENT_REASON='05' then 'anxiety'
			 when EVENT_REASON='01' or EVENT_REASON='02' or EVENT_REASON='03' then 'psychosis'
			 when EVENT_REASON='06' or EVENT_REASON='07' or EVENT_REASON='11' or EVENT_REASON='28' then 'ocd_phobias_ptsd_gampling'
			 when EVENT_REASON= '09' then 'substance'
			 when EVENT_REASON= '12' then 'eating'
			 when EVENT_REASON= '15' then 'self-harm'
			 when EVENT_REASON= '18 'then 'crisis'
			 when EVENT_REASON='13' or EVENT_REASON='27' or EVENT_REASON='29' then 'perinatal'
			 when EVENT_REASON='08' or EVENT_REASON='10' or EVENT_REASON='22' or EVENT_REASON='23' then 'organic'
             when EVENT_REASON='19' or EVENT_REASON='21' then 'attachment_relationship'
			 when EVENT_REASON='20' then 'gender'
			 when EVENT_REASON='14' then 'personality'
			 else null
	  end as 'reason'
INTO [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
FROM (SELECT [CM_PSEUDONYM]
      ,[EVENT_DATE]
      ,[EVENT_REASON]
  FROM [Client_SystemP_RW].[KD_MHSDS_OMOP_Referral]
  WHERE YEAR(EVENT_DATE) = 2021 ) Tbl


  SELECT  M.*
          ,RA1.number as 'ref_reason_anxiety_12'
		  ,RA2.number as 'ref_reason_depression_12'
		  ,RA3.number as 'ref_reason_psychosis_12'
		  ,RA4.number as 'ref_reason_autism_12'
		  ,RA5.number as 'ref_reason_neurodevelopmental_12'
		  ,RA6.number as 'ref_reason_ocd_phobia_12'
		  ,RA7.number as 'ref_reason_substance_12'
		  ,RA8.number as 'ref_reason_eating_12'
		  ,RA9.number as 'ref_reason_selfharm_12'
		  ,RA10.number as 'ref_reason_crisis_12'
		  ,RA11.number as 'ref_reason_perinatal_12'
		  ,RA12.number as 'ref_reason_attachment_12'
		  ,RA13.number as 'ref_reason_gender_12'
		  ,RA14.number as 'ref_reason_personality_12'
		  ,RA15.number as 'ref_reason_organic_12'
  INTO [Client_SystemP_RW].[RP_MHSDS_Referrals_reasons_carecontacts_2021]
  FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_CareContacts_2021] M

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE reason like '%anxiety%'
   GROUP BY CM_PSEUDONYM
  ) RA1
  ON M.[CMv2_Pseudo_Number]= RA1.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%depression%'
   GROUP BY CM_PSEUDONYM
  ) RA2
  ON M.[CMv2_Pseudo_Number] = RA2.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%psychosis%'
   GROUP BY CM_PSEUDONYM
  ) RA3
  ON M.[CMv2_Pseudo_Number] = RA3.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%autism%'
   GROUP BY CM_PSEUDONYM
  ) RA4
  ON M.[CMv2_Pseudo_Number] = RA4.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%neurodevelopmental%'
   GROUP BY CM_PSEUDONYM
  ) RA5
  ON M.[CMv2_Pseudo_Number] = RA5.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%ocd_phobia%'
   GROUP BY CM_PSEUDONYM
  ) RA6
  ON M.[CMv2_Pseudo_Number] = RA6.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%substance%'
   GROUP BY CM_PSEUDONYM
  ) RA7
  ON M.[CMv2_Pseudo_Number] = RA7.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%eating%'
   GROUP BY CM_PSEUDONYM
  ) RA8
  ON M.[CMv2_Pseudo_Number] = RA8.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%self-harm%'
   GROUP BY CM_PSEUDONYM
  ) RA9
  ON M.[CMv2_Pseudo_Number] = RA9.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%crisis%'
   GROUP BY CM_PSEUDONYM
  ) RA10
  ON M.[CMv2_Pseudo_Number] = RA10.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%perinatal%'
   GROUP BY CM_PSEUDONYM
  ) RA11
  ON M.[CMv2_Pseudo_Number] = RA11.CM_PSEUDONYM

  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%attachment%'
   GROUP BY CM_PSEUDONYM
  ) RA12
  ON M.[CMv2_Pseudo_Number] = RA12.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%gender%'
   GROUP BY CM_PSEUDONYM
  ) RA13
  ON M.[CMv2_Pseudo_Number] = RA13.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%personality%'
   GROUP BY CM_PSEUDONYM
  ) RA14
  ON M.[CMv2_Pseudo_Number] = RA14.CM_PSEUDONYM


  LEFT JOIN (
  SELECT CM_PSEUDONYM,
         count(*) as 'number'
   FROM [Client_SystemP_RW].[RP_MHSDS_Referrals_test2] 
   WHERE t.reason like '%organic%'
   GROUP BY CM_PSEUDONYM
  ) RA15
  ON M.[CMv2_Pseudo_Number] = RA15.CM_PSEUDONYM