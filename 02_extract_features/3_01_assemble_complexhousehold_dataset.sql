/****** This is the first script to assemble from different data sources/tables
the features/variables that are needed for the definition and identification of 
households with complex needs.

This scripts links demographic information from the MPI (incl. death and pseudonymised uprn)
with the values of the segmentation table that indicate the presence of a condition or a group of conditions
in the time period relevant to the analysis - the time period need to be specified when the 
segmentation table - in this case [RP103_Segmentation] is created
******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/




DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_1]  

SELECT P.[Pseudo_NHS_Number]
      ,P.[GPPracticeCode]
      ,P.[X_CCG_OF_REGISTRATION]
      ,P.[X_CCG_OF_RESIDENCE]
      ,P.[Dob]
	  ,cast(left(P.Dob,4) as int) as 'Year_of_Birth'
      ,P.[Sex]
      ,P.[EthnicGroup]
      ,P.[Deceased]
	  ,P.[Date_of_Death]
      ,P.[LSOA]
      ,P.[pUPRN]
	  ,P.[NursingCareHomeFlag]
      ,S.[Homeless]
      ,S.[Carer]
      ,S.[AsylumSeeker]
      ,S.[SelfHarm]
      ,S.[H_abuse]
      ,S.[offender]
      ,S.[Substance_or_alcohol]
	  ,S.[freq_ae_attend]
      ,S.[h_looked_after]     
      ,S.[Palliative_EOL_Reg]
      ,S.[Frailty_or_Dementia]
      ,S.[Complex]
      ,S.[Cancer]
      ,S.[LTC]
      ,S.[Learning_Disabilities] as Learning_Disability
	  ,S.[Physical_Disability]
      ,S.[CMHP]
      ,S.[Depression]
      ,S.[Anxiety]
      ,S.[SMI]
      ,S.[Schizophrenia]
      ,S.[Bipolar]
      ,(S.[Other_Psychosis] + S.[Psychotic_disorder]) as 'Other_psychosis'
	  ,S.[CVD]
	  ,S.[Diabetes]
      ,S.[Rheumatology] as Rheumatological
	  ,S.[Epilepsy]
      ,S.[CKD]
      ,S.[CLD]  
      ,S.[Asthma]
      ,S.[COPD]
      ,S.[Neurological]
      ,S.[Psychoactive_substance_misuse]
      ,S.[Alcohol_misuse]
	 
  INTO [Client_SystemP_RW].[RP007_SPHD_1]    
  FROM [Client_SystemP_RW].[RP003_MPI] P

  
  INNER JOIN [Client_SystemP_RW].[RP103_Segmentation] S
  ON P.[Pseudo_NHS_Number] = S.[Pseudo_NHS_Number]