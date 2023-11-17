/****** Script to select on a specific class of medications - antidepressants in this case
from cipha [GP_Medications] ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/



DROP TABLE if exists Client_SystemP_RW.RP201_ADprescriptions

SELECT M.FK_Patient_ID
      ,M.MedicationDate
      ,M.RepeatMedicationFlag
      ,M.FK_Patient_Link_ID
      ,M.FK_Reference_SnomedCT_ID
      ,M.X_CCG_OF_REGISTRATION
      ,M.X_CCG_OF_RESIDENCE
      ,AD.*
      ,P.[Pseudo_NHS_Number]
      ,P.[Sex]
      ,P.[Dob]
  INTO Client_SystemP_RW.RP201_ADprescriptions
  FROM [Client_SystemP].[GP_Medications] M
  INNER JOIN Client_SystemP_RW.RP_ref_ad_meds AD
  ON M.[FK_Reference_SnomedCT_ID]=AD.PK_Reference_SnomedCT_ID
  LEFT JOIN [Client_SystemP].[Patient] P
  ON  M.FK_Patient_ID = P.PK_Patient_ID
  WHERE P.Pseudo_NHS_Number is not null AND
        P.FK_Reference_Tenancy_ID = 2

