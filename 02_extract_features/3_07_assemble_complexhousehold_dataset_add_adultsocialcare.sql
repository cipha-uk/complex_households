/****** This is scripts adds more of the event features:
yearly
usage of adult social care services and their reason and cost

******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/
DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_7]

SELECT P.*
        ,ASC2.*
       ,A.[asc_services_12]
      ,A.[asc_cost_12]
      ,A.[asc_service_reason_physical_12]
      ,A.[asc_service_reason_mental_12]
      ,A.[asc_service_reason_substance_12]
      ,A.[asc_service_reason_social_12]
      ,A.[asc_service_reason_learning_12]
      ,A.[asc_service_reason_sensorycognition_12]
      ,A.[asc_service_reason_carer_12]

INTO  [Client_SystemP_RW].[RP007_SPHD_7] 
FROM  [Client_SystemP_RW].[RP007_SPHD_6] P

LEFT JOIN [Client_SystemP_RW].[RP_ASC_Services_2021] A
ON P.[Pseudo_NHS_Number] = A.[Pseudo_NHS_Number]



LEFT JOIN [Client_SystemP_RW].[RP_ASC_Requests_2021]  ASC2
ON P.[Pseudo_NHS_Number] = ASC3.[Pseudo_NHS_Number]

