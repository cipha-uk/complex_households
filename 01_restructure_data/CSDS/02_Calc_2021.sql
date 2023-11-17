/*
Script: 02_Calc_2021.sql
Description: Calculates counts of Referrals and Contacts by PersonID, Service type, and month of year.  
Depedencies: Read only and Read/Write access to [Client_SystemP] and [Client_SystemP_RW] schemas respectively.
             Tables 
             - [Client_SystemP_RW].[KD_CSDS_CareActivity]
             - [Client_SystemP_RW].[KD_CSDS_CareContact]
             - [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide]
             - [Client_SystemP_RW].[KD_CSDS_Referral]

Author: Konstantinos Daras (Konstantinos.Daras@liverpool.ac.uk)
Date: September 2022
Notes:
  - 21 Sept 2022: [Cipha_Pseudo_Number] renamed to [CMv2_Pseudo_Number]
  - 27 Sept 2022: Replace 'Cipha' prefix with 'CMv2' prefix 

TODO: 
  [DONE] Create Referral and Contacts table by PersonID, Month and Service Type 


LATEST OUTPUTS: 02 May 2023
*/

---------------------------------
-- Output table - 2022
---------------------------------
DECLARE @cnt INT 
DECLARE @year VARCHAR(4)
DECLARE @tstamp VARCHAR(7)
SET @cnt=1
SET @year = '2022'
PRINT @year
-- Loop for each month in 2022
DROP TABLE IF EXISTS #_temp_Output
WHILE ( @cnt <= 12)
BEGIN
    -- Referrals
    DROP TABLE IF EXISTS #_tmp_Ref
    SELECT X.[CMv2_Pseudo_Number] AS [CMv2_Pseudo_Number], COUNT(*) AS Ref_Total, SUM([GType01]) AS R_SType01, 
          SUM([GType02]) AS R_SType02, SUM([GType03]) AS R_SType03,
          SUM([GType04]) AS R_SType04, SUM([GType05]) AS R_SType05,
          SUM([GType06]) AS R_SType06, SUM([GType07]) AS R_SType07,
          SUM([GType08]) AS R_SType08, SUM([GType09]) AS R_SType09,
          SUM([GType10]) AS R_SType10, SUM([GType11]) AS R_SType11,
          SUM([GType12]) AS R_SType12, SUM([GType98]) AS R_SType98
    INTO #_tmp_Ref      
    FROM (SELECT A.[CMv2_Pseudo_Number], [ReferralRequest_ReceivedDate], [GType01], 
          [GType02], [GType03], [GType04], [GType05],
          [GType06], [GType07], [GType08], [GType09],
          [GType10], [GType11], [GType12], [GType98]
      FROM [Client_SystemP_RW].[KD_CSDS_Referral] AS A
      LEFT JOIN [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide] AS B
        ON A.CMv2_Pseudo_Number = B.CMv2_Pseudo_Number AND
          A.Unique_ServiceRequestID = B.Unique_ServiceRequestID    
      ) AS X

    WHERE DATEPART(yyyy, X.[ReferralRequest_ReceivedDate])= @year AND 
          DATEPART(mm, X.[ReferralRequest_ReceivedDate])= CAST(@cnt AS VARCHAR(4)) 
      GROUP BY X.[CMv2_Pseudo_Number]

    -- Contacts
    DROP TABLE IF EXISTS #_tmp_Cont
    SELECT X.[CMv2_Pseudo_Number] AS [CMv2_Pseudo_Number], COUNT(*) AS Cont_Total, SUM([GType01]) AS C_SType01, 
          SUM([GType02]) AS C_SType02, SUM([GType03]) AS C_SType03,
          SUM([GType04]) AS C_SType04, SUM([GType05]) AS C_SType05,
          SUM([GType06]) AS C_SType06, SUM([GType07]) AS C_SType07,
          SUM([GType08]) AS C_SType08, SUM([GType09]) AS C_SType09,
          SUM([GType10]) AS C_SType10, SUM([GType11]) AS C_SType11,
          SUM([GType12]) AS C_SType12, SUM([GType98]) AS C_SType98
    INTO #_tmp_Cont      
    FROM (SELECT A.[CMv2_Pseudo_Number], [Contact_Date], [GType01], 
          [GType02], [GType03], [GType04], [GType05],
          [GType06], [GType07], [GType08], [GType09],
          [GType10], [GType11], [GType12], [GType98]
      FROM [Client_SystemP_RW].[KD_CSDS_CareContact] AS A
      LEFT JOIN [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide] AS B
        ON A.CMv2_Pseudo_Number = B.CMv2_Pseudo_Number AND
          A.Unique_ServiceRequestID = B.Unique_ServiceRequestID    --  
      ) AS X

    WHERE DATEPART(yyyy, X.[Contact_Date])= @year AND 
          DATEPART(mm, X.[Contact_Date])= CAST(@cnt AS VARCHAR(4))
      GROUP BY X.[CMv2_Pseudo_Number]

    -- FULL JOIN Referrals and Contacts to keep patients with partial missing data. 
    DROP TABLE IF EXISTS #_tmp_RC
    SELECT CASE WHEN A.[CMv2_Pseudo_Number]  IS NULL THEN B.[CMv2_Pseudo_Number]
                ELSE A.[CMv2_Pseudo_Number] END AS [CMv2_Pseudo_Number], 
            Ref_Total, R_SType01, 
            R_SType02, R_SType03, R_SType04, R_SType05,
            R_SType06, R_SType07, R_SType08, R_SType09,
            R_SType10, R_SType11, R_SType12, R_SType98,
            Cont_Total, C_SType01, C_SType02, C_SType03,
            C_SType04, C_SType05, C_SType06, C_SType07,
            C_SType08, C_SType09, C_SType10, C_SType11,
            C_SType12, C_SType98
    INTO #_tmp_RC
    FROM #_tmp_Ref AS A
    FULL OUTER JOIN #_tmp_Cont AS B
    ON A.[CMv2_Pseudo_Number] = B.[CMv2_Pseudo_Number]

    -- Add Timestamp column (YYYY-MM)
    SET @tstamp = CONCAT(@year,'-',RIGHT('00' + CONVERT(VARCHAR, @cnt), 2))
    SELECT @tstamp
    ALTER TABLE #_tmp_RC ADD TStamp VARCHAR(7)
    UPDATE #_tmp_RC SET TStamp = @tstamp

    IF @cnt = 1
      SELECT * INTO #_temp_Output FROM #_tmp_RC
    ELSE
      INSERT INTO #_temp_Output SELECT * FROM #_tmp_RC 
    
    SET @cnt  = @cnt  + 1
END


DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2022]
SELECT * INTO [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2022] FROM #_temp_Output
DROP TABLE IF EXISTS #_temp_Output


-- TEST
SELECT COUNT(*) AS CNT FROM [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2022]
SELECT TStamp, COUNT(*) AS CNT FROM [Client_SystemP_RW].[KD_CSDS_Referrals_CareContacts_2022]
  GROUP BY TStamp
  ORDER BY TStamp

---------------------------------