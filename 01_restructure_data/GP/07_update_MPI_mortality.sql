
/*** Author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------
/* This script links mortality records to MPI */
---------------------------------------------------------------------------------------------------------------------------------------------

SELECT P.*
      ,[REG_DATE_OF_DEATH] as Date_of_Death
      ,[DEC_OCC_TYPE] as Dec_occupation
      ,[POD_CODE] as Place_of_Death_Code
      ,[POD_NHS_ESTABLISHMENT] as Place_of_Death_NHS_Establishment
      ,[POD_ESTABLISHMENT_TYPE] as Place_of_Death_Establishment_Type
      ,[S_UNDERLYING_COD_ICD10] as Underlying_Cause_of_Death
      ,[S_COD_CODE_1] as Primary_Cause_of_Death
      ,[S_COD_CODE_2] as Secondary_Cause_of_Death
  INTO Client_SystemP_RW.RP002_MPI
  FROM Client_SystemP_RW.RP001_MPI P
  LEFT JOIN [Client_ICS].[vw_Mortality] M
  ON  P.Pseudo_NHS_Number = M.DEC_NHS_NUMBER