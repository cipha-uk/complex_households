/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates restructures and recodes and provides yearly counts
of events in the adult social care cycle

******/


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

DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Services_2021] 
DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Assessments_2021] 
DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Requests_2021] 
DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Reviews_2021] 


/****REQUESTS

here there is a lot of recoding and relabelling ******/

SELECT S.[Der_pseudo_nhsnumber_Traced] as Pseudo_NHS_Number
       ,count(*) as 'asc_requests_12'
	   ,sum(asc_service_reason_physical) as 'asc_request_reason_physical_12'
	   ,sum(asc_service_reason_mentalhealth) as 'asc_request_reason_mental_12'
	   ,sum(asc_service_reason_substance) as 'asc_request_reason_substance_12'
	    ,sum(asc_service_reason_social) as 'asc_request_reason_social_12'
	   ,sum(asc_service_reason_learning) as 'asc_request_reason_learning_12'
	   ,sum(asc_service_reason_sensorycognition) as 'asc_request_reason_sensorycognition_12'
	   ,sum(asc_service_reason_carer) as 'asc_request_reason_carer_12'
INTO [Client_SystemP_RW].[RP_ASC_Requests_2021] 
FROM
(SELECT *
         ,CASE
	   WHEN Primary_Support_Reason LIKE '%physical%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_physical
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%mental%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_mentalhealth	   
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%substance%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_substance
	   ,CASE
	   WHEN (Primary_Support_Reason LIKE '%isolation%') or (Primary_Support_Reason LIKE '%other%') THEN 1
	   ELSE 0
	   END as asc_service_reason_social	 
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%learning%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_learning
	   ,CASE
	   WHEN (Primary_Support_Reason LIKE '%sensory%') or (Primary_Support_Reason LIKE '%cognition%') THEN 1
	   ELSE 0
	   END as asc_service_reason_sensorycognition
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%carer%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_carer
  FROM [Client_SystemP_RW].[RP_ASC_Requests] 
  WHERE YEAR([Event_Start_Date]) = 2021) S
  GROUP BY S.[Der_pseudo_nhsnumber_Traced]


/****   SERVICES
- here there is quite a lot of work not just for restructuring but
for calculating the cost of the service as well ****/
SELECT S.Pseudo_NHS_Number
       ,count(*) as 'asc_services_12'
	   ,sum(S.weeks*S.Unit_Cost*S.per_week) as 'asc_cost_12'
	   ,sum(asc_service_reason_physical) as 'asc_service_reason_physical_12'
	   ,sum(asc_service_reason_mentalhealth) as 'asc_service_reason_mental_12'
	   ,sum(asc_service_reason_substance) as 'asc_service_reason_substance_12'
	    ,sum(asc_service_reason_social) as 'asc_service_reason_social_12'
	   ,sum(asc_service_reason_learning) as 'asc_service_reason_learning_12'
	   ,sum(asc_service_reason_sensorycognition) as 'asc_service_reason_sensorycognition_12'
	   ,sum(asc_service_reason_carer) as 'asc_service_reason_carer_12'
INTO [Client_SystemP_RW].[RP_ASC_Services_2021] 
FROM
(SELECT [Der_pseudo_nhsnumber_Traced] as 'Pseudo_NHS_Number'
      ,[Gender]
      ,[Ethnicity]
      ,[Date_of_Death]
      ,[Primary_Support_Reason]
	  ,CASE
	   WHEN Primary_Support_Reason LIKE '%physical%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_physical
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%mental%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_mentalhealth	   
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%substance%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_substance
	   ,CASE
	   WHEN (Primary_Support_Reason LIKE '%isolation%') or (Primary_Support_Reason LIKE '%other%') THEN 1
	   ELSE 0
	   END as asc_service_reason_social	 
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%learning%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_learning
	   ,CASE
	   WHEN (Primary_Support_Reason LIKE '%sensory%') or (Primary_Support_Reason LIKE '%cognition%') THEN 1
	   ELSE 0
	   END as asc_service_reason_sensorycognition
	   ,CASE
	   WHEN Primary_Support_Reason LIKE '%carer%'  THEN 1
	   ELSE 0
	   END as asc_service_reason_carer
      ,[Event_Type]
      ,[Event_Start_Date]
	  ,[Event_End_Date]
      ,[Unit_Cost]
      ,[Cost_Frequency_(Unit_Type)]
      ,[Planned_units_per_week]
	  ,CASE
	   WHEN Planned_units_per_week like '%one%off%' THEN  (1/(datediff(ww,Event_Start_Date, CAST('20211231' AS DATE))))
	   WHEN Planned_units_per_week like '%one%off%' THEN 1
	   ELSE Planned_units_per_week
	   END as 'per_week'
	  ,datediff(ww,Event_Start_Date, CAST('20211231' AS DATE)) as weeks
      ,[Der_pseudo_nhsnumber]
  FROM [Client_SystemP_RW].[RP_ASC_Services] 
  WHERE YEAR([Event_Start_Date]) = 2021) S
  GROUP BY S.Pseudo_NHS_Number

 

 /*** ASSESSMENTS ****/

SELECT S.[Der_pseudo_nhsnumber_Traced] as Pseudo_NHS_Number
       ,count(*) as 'asc_requests_12'
INTO [Client_SystemP_RW].[RP_ASC_Assessments_2021] 
FROM
(SELECT *
  FROM [Client_SystemP_RW].[RP_ASC_Assessments] 
  WHERE YEAR([Event_Start_Date]) = 2021) S
  GROUP BY S.[Der_pseudo_nhsnumber_Traced]



  /******REVIEWS********/

  


SELECT S.[Der_pseudo_nhsnumber_Traced] as Pseudo_NHS_Number
       ,count(*) as 'asc_reviews_12'
INTO [Client_SystemP_RW].[RP_ASC_Reviews_2021] 
FROM
(SELECT *
  FROM [Client_SystemP_RW].[RP_ASC_Reviews] 
  WHERE YEAR([Event_Start_Date]) = 2021) S
  GROUP BY S.[Der_pseudo_nhsnumber_Traced]
