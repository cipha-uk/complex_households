/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to bring all the mental health related A&E attendances in one table
 - deduplicating where relevant ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/


DROP TABLE if exists Client_SystemP_RW.RP_MentaHealth_AEAttendances_v1


(SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Substance' as Reason
	  ,4 as 'priority'
  INTO Client_SystemP_RW.RP_MentaHealth_AEAttendances_v1
  FROM [Client_SystemP_RW].[RP_AEAttendances_substance_v1])

  union

 (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Alcohol' as Reason
	  ,5 as 'priority'
  FROM [Client_SystemP_RW].[RP_AEAttendances_alcohol_v1])

  union

  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Self-harm' as Reason
	  ,1 as 'priority'
  FROM [Client_SystemP_RW].[RP_AEAttendances_selfharm_v3])

  union

  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Eating disorder' as Reason
	  ,3 as 'priority'
  FROM [Client_SystemP_RW].[RP_AEAttendances_eatingdisorder_v2])

  union

  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Other mental health: Anxiety' as Reason
	  ,8 as 'priority'
  FROM [Client_SystemP_RW].[RP_AEAttendances_anxiety_v2])

  union

  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Other mental health: Psychosis' as Reason
	  ,7 as 'priority'
  FROM Client_SystemP_RW.RP_AEAttendances_smi_v2)

  union
  
  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Injury due to alcohol or drug' as Reason
	  ,6 as 'priority'
  FROM [Client_SystemP_RW].[RP_ECDS_AlcoholDrugInvolvment_v3])

  union

  (SELECT [EC_Ident]
      ,[CMv2_Pseudo_Number]
      ,[Der_EC_Arrival_Date_Time] as EventDate
      ,'Injury due to self-harm intent' as Reason
	  ,2 as 'priority'
  FROM [Client_SystemP_RW].[RP_ECDS_SelfHarmIntent_v2])


 /*** deduplicate ***/

 DROP TABLE if exists [Client_SystemP_RW].#RP_AAE_temp_11
DROP TABLE if exists [Client_SystemP_RW].[RP_MentaHealth_AEAttendances_v11]

SELECT [EC_Ident]
       ,count(*) as num
	   ,min(priority) as 'priority'
  INTO [Client_SystemP_RW].#RP_AAE_temp_11
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances_v1]
  GROUP BY [EC_Ident]


  SELECT M.*
        ,S.num
        

  INTO [Client_SystemP_RW].[RP_MentaHealth_AEAttendances_v11]
  FROM [Client_SystemP_RW].[RP_MentaHealth_AEAttendances_v1] as M
 

  INNER JOIN [Client_SystemP_RW].#RP_AAE_temp_11 as S
  ON M.EC_Ident = S.EC_Ident AND M.[priority]=S.[priority]