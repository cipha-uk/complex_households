/****** Script to create antidepressant reference ******/
/*** links cipha meds ids with bnf codes   ***/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/




   SELECT B.*
     ,S.PK_Reference_SnomedCT_ID
     ,S.ConceptID
  INTO Client_SystemP_RW.RP_ref_ad_meds
  FROM Client_SystemP_RW.RP_ref_bnf_snomed_map B
  INNER JOIN Client_SystemP.Reference_SnomedCT S
  ON B.SNOMED_Code=S.ConceptID
  WHERE B.BNF_Code LIKE '0403%'
 
  