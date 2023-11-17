/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script creates takes the adult social care activity tables that are structured according to 
the local authoritis client level returns
not all local authorities in C&M submit the data:

here the forms are separated into:
- services
- requests <- are the equivalent of referrals
- reviews
- assessments

******/

/***TO DO at some stage the name of the field corresponding to the CM pseudonym changed and I still
need to check all code for it****/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/
DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Services]

SELECT [LA_Name] 
      ,[Gender]
      ,[Ethnicity]
      ,[Date_of_Death]
      ,[Primary_Support_Reason]
      ,[Event_Type]
      ,[Event_Start_Date]
      ,[Event_End_Date]
      ,[Unit_Cost]
      ,[Cost_Frequency_(Unit_Type)]
      ,[Planned_units_per_week]
      ,[Der_pseudo_nhsnumber]
      ,[Der_pseudo_nhsnumber_Traced]
  INTO [Client_SystemP_RW].[RP_ASC_Services]
  FROM [Client_ICS].[vw_Adult_Social_Care]
  WHERE Event_Type = 'Service'



DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Requests]

  SELECT [LA_Name]
      ,[Gender]
      ,[Ethnicity]
      ,[Date_of_Death]
      ,[Primary_Support_Reason]
      ,[Event_Type]
      ,[Event_Start_Date]
      ,[Event_End_Date]
      ,[Event_Outcome]
      ,[Der_pseudo_nhsnumber]
      ,[Der_pseudo_nhsnumber_Traced]    
  INTO [Client_SystemP_RW].[RP_ASC_Requests]
  FROM [Client_ICS].[vw_Adult_Social_Care]
  WHERE Event_Type = 'Request'


  DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Reviews]

  SELECT [LA_Name]
      ,[Gender]
      ,[Ethnicity]
      ,[Date_of_Death]
      ,[Primary_Support_Reason]
      ,[Event_Type]
      ,[Event_Start_Date]
      ,[Event_End_Date]
      ,[Event_Outcome]
	  ,[Review_Reason]
      ,[Review_Outcomes_Achieved]
      ,[Der_pseudo_nhsnumber]
      ,[Der_pseudo_nhsnumber_Traced]    
  INTO [Client_SystemP_RW].[RP_ASC_Reviews]
  FROM [Client_ICS].[vw_Adult_Social_Care]
  WHERE Event_Type = 'Review'


  DROP TABLE if exists [Client_SystemP_RW].[RP_ASC_Assessments]

  SELECT [LA_Name]
      ,[Gender]
      ,[Ethnicity]
      ,[Date_of_Death]
      ,[Primary_Support_Reason]
      ,[Event_Type]
      ,[Event_Start_Date]
      ,[Event_End_Date]
      ,[Event_Outcome]
	  ,[Assessment_Type]
      ,[Eligible_Needs_Identified]
      ,[Informal_Carer_involved_in_Assessment]
      ,[Der_pseudo_nhsnumber]
      ,[Der_pseudo_nhsnumber_Traced]    
  INTO [Client_SystemP_RW].[RP_ASC_Assessments]
  FROM [Client_ICS].[vw_Adult_Social_Care]
  WHERE Event_Type = 'Assessment'
