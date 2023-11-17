
/*** Author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------
/* this links the table with pseudo-uprns with the mpi */
---------------------------------------------------------------------------------------------------------------------------------------------

SELECT P.*
      ,U.Der_Pseudo_UPRN as pUPRN
      ,U.living_with_over_64_flag
      ,U.Rural_Urban_Classification
      ,U.property_type
      ,U.OS_Property_Classification
  INTO Client_SystemP_RW.RP003_MPI
  FROM Client_SystemP_RW.RP002_MPI P
  LEFT JOIN [Client_SystemP].[PDS_UPRN_Indicators] U
  ON  P.Pseudo_NHS_Number = U.Der_Pseudo_NHS_Number