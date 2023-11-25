/****** This is scripts adds some more conditions from the conditions table
these are important for the kind of analysis of complex households since it is
about children and families. This is an example of how to add other variables of interest
from the conditions table -
This starts adding some of the event features:
yearly
antidepressant prescriptions
emergency admissions for all causes
elective admissions for all causes
A&E attendances 
and their cost
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

DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_3]

SELECT P.*
       ,AD.Antidepressants as 'gp_antidepressant_rx_12'
	   ,ELEC.[AEAttendances12] as 'admissions_electives_12'
       ,ELEC.[AECost] as 'ElectiveAdmissions_cost_12'
	   ,EMER.[AEAttendances12] as 'admissions_emergency_12'
       ,EMER.[AECost] as 'EmergencyAdmissions_cost_12'
	   ,ECDS.[AEAttendances12] as 'aae1a2_attend_12'
       ,ECDS.[AECost] as 'AAEAttendances_cost_12'
	   
      
INTO  [Client_SystemP_RW].[RP007_SPHD_3] 
FROM  [Client_SystemP_RW].[RP007_SPHD_2] P

LEFT JOIN [Client_SystemP_RW].[RP_ADprescriptions_2021] AD
ON P.[Pseudo_NHS_Number] = AD.[Pseudo_NHS_Number]


LEFT JOIN [Client_SystemP_RW].[RP_ElectiveAdmissions_2021] ELEC
ON P.[Pseudo_NHS_Number] = ELEC.[Pseudo_NHS_Number]  

LEFT JOIN [Client_SystemP_RW].[RP_EmergencyAdmissions_2021] EMER
ON P.[Pseudo_NHS_Number] = EMER.[Pseudo_NHS_Number] 

LEFT JOIN [Client_SystemP_RW].[RP_AEAttendances12_2021] ECDS
ON P.[Pseudo_NHS_Number] = ECDS.[Pseudo_NHS_Number] 


LEFT JOIN 
(SELECT count(distinct([EC_Ident])) as 'Number_AE_selfharm'
      ,[CMv2_Pseudo_Number]     
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances]
  WHERE Reason like '%self%' AND YEAR(EventDate)=2021
  GROUP BY [CMv2_Pseudo_Number] ) MH_AE1

  ON P.[Pseudo_NHS_Number] = MH_AE1.[CMv2_Pseudo_Number]


  LEFT JOIN 
(SELECT count(distinct([EC_Ident])) as 'Number_AE_alcohol'
      ,[CMv2_Pseudo_Number]     
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances]
  WHERE Reason like '%alcohol%' AND YEAR(EventDate)=2021
  GROUP BY [CMv2_Pseudo_Number] ) MH_AE2

  ON P.[Pseudo_NHS_Number] = MH_AE2.[CMv2_Pseudo_Number]

   LEFT JOIN 
(SELECT count(distinct([EC_Ident])) as 'Number_AE_substance'
      ,[CMv2_Pseudo_Number]     
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances]
  WHERE Reason like '%substance%' AND YEAR(EventDate)=2021
  GROUP BY [CMv2_Pseudo_Number] ) MH_AE3

  ON P.[Pseudo_NHS_Number] = MH_AE3.[CMv2_Pseudo_Number]

   LEFT JOIN 
(SELECT count(distinct([EC_Ident])) as 'Number_AE_eating'
      ,[CMv2_Pseudo_Number]     
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances]
  WHERE Reason like '%eating%' AND YEAR(EventDate)=2021
  GROUP BY [CMv2_Pseudo_Number] ) MH_AE4

  ON P.[Pseudo_NHS_Number] = MH_AE4.[CMv2_Pseudo_Number]

   LEFT JOIN 
(SELECT count(distinct([EC_Ident])) as 'Number_AE_otherpsychological'
      ,[CMv2_Pseudo_Number]     
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances]
  WHERE Reason like '%other%' AND YEAR(EventDate)=2021
  GROUP BY [CMv2_Pseudo_Number] ) MH_AE5

  ON P.[Pseudo_NHS_Number] = MH_AE5.[CMv2_Pseudo_Number]


LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,[diagnosis]
      ,[EmergencyAdmissions]
      ,[Cost]
  FROM [Client_SystemP_RW].[RP_MentalHealth_EmergencyAdmissions_2021]
  WHERE diagnosis like '%self%harm%') MH_APC1
  ON P.[Pseudo_NHS_Number] = MH_APC1.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,[diagnosis]
      ,[EmergencyAdmissions]
      ,[Cost]
  FROM [Client_SystemP_RW].[RP_MentalHealth_EmergencyAdmissions_2021]
  WHERE diagnosis like '%alcohol%') MH_APC2
  ON P.[Pseudo_NHS_Number] = MH_APC2.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,[diagnosis]
      ,[EmergencyAdmissions]
      ,[Cost]
  FROM [Client_SystemP_RW].[RP_MentalHealth_EmergencyAdmissions_2021]
  WHERE diagnosis like '%substance%') MH_APC3
  ON P.[Pseudo_NHS_Number] = MH_APC3.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,[diagnosis]
      ,[EmergencyAdmissions]
      ,[Cost]
  FROM [Client_SystemP_RW].[RP_MentalHealth_EmergencyAdmissions_2021]
  WHERE diagnosis like '%eating%') MH_APC4
  ON P.[Pseudo_NHS_Number] = MH_APC4.[Pseudo_NHS_Number]

  LEFT JOIN(
  SELECT [Pseudo_NHS_Number]
      ,[diagnosis]
      ,[EmergencyAdmissions]
      ,[Cost]
  FROM [Client_SystemP_RW].[RP_MentalHealth_EmergencyAdmissions_2021]
  WHERE diagnosis like '%other%') MH_APC5
  ON P.[Pseudo_NHS_Number] = MH_APC5.[Pseudo_NHS_Number]

