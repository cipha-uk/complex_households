/****** This is scripts adds some more conditions from the conditions table
these are important for the kind of analysis of complex households since it is
about children and families. This is an example of how to add other variables of interest
from the conditions table -
This adds more of the event features:
yearly
A&E attendances for mental health reasons
Emergency admissions for mental health reasons
******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/

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

DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_4]

SELECT P.*
	   ,MH_AE1.ECDS_Num_selfharm as 'aae_selfharm_12'
	   ,MH_AE2.Num_ECDS_alcohol as 'aae_alcohol_12'
	   ,MH_AE3.Num_ECDS_substance as 'aae_substance_12'
	   ,MH_AE4.Num_ECDS_eating as 'aae_eating_12'
	   ,MH_AE5.Num_ECDS_othermentalhealth as 'aae_otherpsych_12'
	   ,MH_APC1.[EmergencyAdmissions] as 'emadm_selfharm_12'
	   ,MH_APC2.[EmergencyAdmissions] as 'emadm_alcohol_12'
	   ,MH_APC3.[EmergencyAdmissions] as 'emadm_substance_12'
	   ,MH_APC4.[EmergencyAdmissions] as 'emadm_eating_12'
	   ,MH_APC5.[EmergencyAdmissions] as 'emadm_otherpsych_12'  
	   
INTO  [Client_SystemP_RW].[RP007_SPHD_4] 
FROM  [Client_SystemP_RW].[RP007_SPHD_3] P

LEFT JOIN [Client_SystemP_RW].[RP_ECDS_SelfHarm_2021] MH_AE1
ON P.[Pseudo_NHS_Number] = MH_AE1.CMv2_Pseudo_Number

LEFT JOIN [Client_SystemP_RW].[RP_ECDS_alcohol_2021] MH_AE2
ON P.[Pseudo_NHS_Number] = MH_AE2.CMv2_Pseudo_Number

LEFT JOIN [Client_SystemP_RW].[RP_ECDS_substance_2021] MH_AE3
ON P.[Pseudo_NHS_Number] = MH_AE3.CMv2_Pseudo_Number

LEFT JOIN [Client_SystemP_RW].[RP_ECDS_eating_2021] MH_AE4
ON P.[Pseudo_NHS_Number] = MH_AE4.CMv2_Pseudo_Number

LEFT JOIN [Client_SystemP_RW].[RP_ECDS_othermentalhealth_2021] MH_AE5
ON P.[Pseudo_NHS_Number] = MH_AE5.CMv2_Pseudo_Number

LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,count(*) as 'EmergencyAdmissions'
   
  FROM [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]
  WHERE diagnosis like '%self%harm%' AND YEAR(EventDate)=2021
  GROUP BY  [Pseudo_NHS_Number]) MH_APC1
  ON P.[Pseudo_NHS_Number] = MH_APC1.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,count(*) as 'EmergencyAdmissions'
   
  FROM [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]
  WHERE diagnosis like '%alcohol%'AND YEAR(EventDate)=2021
  GROUP BY  [Pseudo_NHS_Number]) MH_APC2
  ON P.[Pseudo_NHS_Number] = MH_APC2.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,count(*) as 'EmergencyAdmissions'
   
  FROM [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]
  WHERE diagnosis like '%substance%' AND YEAR(EventDate)=2021
  GROUP BY  [Pseudo_NHS_Number]) MH_APC3
  ON P.[Pseudo_NHS_Number] = MH_APC3.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,count(*) as 'EmergencyAdmissions'
   
  FROM [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]
  WHERE diagnosis like '%eating%' AND YEAR(EventDate)=2021
  GROUP BY  [Pseudo_NHS_Number]) MH_APC4
  ON P.[Pseudo_NHS_Number] = MH_APC4.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,count(*) as 'EmergencyAdmissions'
   
  FROM [Client_SystemP_RW].[RP_vw_SUS_APC_MH_EmergencyAdmissions]
  WHERE diagnosis like '%other%' AND YEAR(EventDate)=2021
  GROUP BY  [Pseudo_NHS_Number]) MH_APC5
  ON P.[Pseudo_NHS_Number] = MH_APC5.[Pseudo_NHS_Number]
