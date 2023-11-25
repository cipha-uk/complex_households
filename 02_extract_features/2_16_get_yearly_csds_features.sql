/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates takes the yearly summaries of activity from the system p data model for
CSDS [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2021] which contain monthly counts
 
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

DROP TABLE if exists [Client_SystemP_RW].[RP_CSDS_Referrals_CareContacts_2021]   


SELECT [CMv2_Pseudo_Number]
      ,sum ([Ref_Total]) as 'cs_referrals_tot_12'
      ,sum([R_SType01]) as 'cs_ref_service_alliedhp_12'
      ,sum([R_SType02]) as 'cs_ref_service_audiology_12'
      ,sum([R_SType03]) as 'cs_ref_service_rehabilitation_12'
      ,sum([R_SType04]) as 'cs_ref_service_children_12'
      ,sum([R_SType05]) as 'cs_ref_service_healthvisitormidwife_12'
      ,sum([R_SType06]) as 'cs_ref_service_medicaldental_12'
      ,sum([R_SType07]) as 'cs_ref_service_nursing_12'
      ,sum([R_SType08]) as 'cs_ref_service_palliative_12'
      ,sum([R_SType09]) as 'cs_ref_service_podiatry_12'
      ,sum([R_SType10]) as 'cs_ref_service_singlecondition_12'
      ,sum([R_SType11]) as 'cs_ref_service_wheelchair_12'
      ,sum([R_SType12]) as 'cs_ref_service_other_12'
      ,sum([R_SType98]) as 'cs_ref_service_unknown_12'
      ,sum([Cont_Total]) as 'cs_contacts_tot_12'
      ,sum([C_SType01]) as 'cs_cont_service_alliedhp_12'
      ,sum([C_SType02]) as 'cs_cont_service_audiology_12'
      ,sum([C_SType03]) as 'cs_cont_service_rehabilitation_12'
      ,sum([C_SType04]) as 'cs_cont_service_children_12'
      ,sum([C_SType05]) as 'cs_cont_service_healthvisitormidwife_12'
      ,sum([C_SType06]) as 'cs_cont_service_medicaldental_12'
      ,sum([C_SType07]) as 'cs_cont_service_nursing_12'
      ,sum([C_SType08]) as 'cs_cont_service_palliative_12'
      ,sum([C_SType09]) as 'cs_cont_service_podiatry_12'
      ,sum([C_SType10]) as 'cs_cont_service_singlecondition_12'
      ,sum([C_SType11]) as 'cs_cont_service_wheelchair_12'
      ,sum([C_SType12]) as 'cs_cont_service_other_12'
      ,sum([C_SType98]) as 'cs_cont_service_unknown_12'
  INTO [Client_SystemP_RW].[RP_CSDS_Referrals_CareContacts_2021]    
  FROM [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2021] 

  GROUP BY [CMv2_Pseudo_Number]