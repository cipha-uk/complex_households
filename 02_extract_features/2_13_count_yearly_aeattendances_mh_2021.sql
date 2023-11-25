/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates a table for each mental health reason and counts yearly attendances to A&E
per person per specific reason ******/

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


DROP TABLE if exists Client_SystemP_RW.RP_ECDS_substance_2021
DROP TABLE if exists Client_SystemP_RW.RP_ECDS_othermentalhealth_2021
DROP TABLE if exists Client_SystemP_RW.RP_ECDS_alcohol_2021
DROP TABLE if exists [Client_SystemP_RW].[RP_ECDS_SelfHarm_2021]
DROP TABLE if exists Client_SystemP_RW.RP_ECDS_eating_2021

SELECT count(distinct(Tbl.EC_Ident)) as 'Num_ECDS_eating'
      ,[CMv2_Pseudo_Number]
  INTO Client_SystemP_RW.RP_ECDS_eating_2021
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances_v11]
  WHERE YEAR(EventDate) = 2021 AND Reason like 'Eating%' AND [CMv2_Pseudo_Number] is not null
  GROUP BY CMv2_Pseudo_Number

SELECT count(distinct(Tbl.EC_Ident)) as 'ECDS_Num_selfharm'
       ,Tbl.CMv2_Pseudo_Number
INTO [Client_SystemP_RW].[RP_ECDS_SelfHarm_2021]
FROM Client_SystemP_RW.[RP_MentaHealth_AEAttendances_v11] 
  WHERE YEAR(EventDate) = 2021 AND Reason like 'Self%harm%' AND [CMv2_Pseudo_Number] is not null
  GROUP BY CMv2_Pseudo_Number

SELECT count(distinct(tbl.EC_Ident)) as 'Num_ECDS_alcohol'
       ,Tbl.CMv2_Pseudo_Number

INTO Client_SystemP_RW.RP_ECDS_alcohol_2021
FROM Client_SystemP_RW.[RP_MentaHealth_AEAttendances_v11]  
  WHERE YEAR(EventDate) = 2021 AND Reason like 'Alcohol%' AND [CMv2_Pseudo_Number] is not null
  GROUP BY CMv2_Pseudo_Number



SELECT count(distinct(EC_Ident)) as 'Num_ECDS_substance'
       ,CMv2_Pseudo_Number

  FROM Client_SystemP_RW.[RP_MentaHealth_AEAttendances_v11]

  WHERE YEAR(EventDate)=2021 AND [CMv2_Pseudo_Number] is not null AND Reason like 'Substance' 
  GROUP BY CMv2_Pseudo_Number
      

SELECT  count(distinct(EC_Ident)) as 'Num_ECDS_othermentalhealth'
        ,CMv2_Pseudo_Number

  INTO Client_SystemP_RW.RP_ECDS_othermentalhealth_2021
  FROM Client_SystemP_RW.[RP_MentaHealth_AEAttendances_v11] 
  WHERE YEAR(EventDate) = 2021 AND Reason like 'Other%' 
  GROUP BY CMv2_Pseudo_Number

