/*
Script: 02_Calc_2021.sql
Description: Calculates counts of Referrals and Contacts by PersonID, Service type, and month of year.  
Depedencies: Read only and Read/Write access to [Client_SystemP] and [Client_SystemP_RW] schemas respectively.
             Tables 
             - [Client_SystemP_RW].[KD_MHSDS_CareActivity]
             - [Client_SystemP_RW].[KD_MHSDS_CareContact]
             - [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide]
             - [Client_SystemP_RW].[KD_MHSDS_Referral]

Author: Konstantinos Daras (Konstantinos.Daras@liverpool.ac.uk)
Date: September 2022
Notes:
  - 2019-04 onwards counts per month have a threefold increase! Possible Quality issues for data pre - April 2019.  
  - 

TODO: 
  [DONE] Create Referral and Contacts table by PersonID, Month and Service Type 

LATEST OUTPUTS: 03 May 2023
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
    SELECT X.[CMv2_Pseudo_Number] AS [CMv2_Pseudo_Number], COUNT(*) AS Ref_Total, SUM([MH01]) AS R_SType01, 
          SUM([MH02]) AS R_SType02, SUM([MH03]) AS R_SType03,
          SUM([MH04]) AS R_SType04, SUM([MH05]) AS R_SType05,
          SUM([MH06]) AS R_SType06, SUM([MH07]) AS R_SType07,
          SUM([MH08]) AS R_SType08, SUM([MH09]) AS R_SType09,
          SUM([MH10]) AS R_SType10, SUM([MH11]) AS R_SType11,
          SUM([MH12]) AS R_SType12, SUM([MH13]) AS R_SType13,
          SUM([MH14]) AS R_SType14, SUM([MH15]) AS R_SType15,
          SUM([MH16]) AS R_SType16, SUM([MH17]) AS R_SType17,
          SUM([MH18]) AS R_SType18, SUM([MH19]) AS R_SType19,
          SUM([MH20]) AS R_SType20, SUM([MH21]) AS R_SType21,
          SUM([MH22]) AS R_SType22, SUM([MH23]) AS R_SType23,
          SUM([MH24]) AS R_SType24, SUM([MH25]) AS R_SType25,
          SUM([MH26]) AS R_SType26, SUM([MH98]) AS R_SType98
    INTO #_tmp_Ref      
    FROM (SELECT A.[CMv2_Pseudo_Number], [ReferralRequest_ReceivedDate], [MH01], 
          [MH02], [MH03], [MH04], [MH05],
          [MH06], [MH07], [MH08], [MH09],
          [MH10], [MH11], [MH12], [MH13],
          [MH14], [MH15], [MH16], [MH17],
          [MH18], [MH19], [MH20], [MH21],
          [MH22], [MH23], [MH24], [MH25],
          [MH26], [MH98]
      FROM [Client_SystemP_RW].[KD_MHSDS_Referral] AS A
      LEFT JOIN [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide] AS B
        ON A.CMv2_Pseudo_Number = B.CMv2_Pseudo_Number AND
          A.Unique_ServiceRequestID = B.Unique_ServiceRequestID    
      ) AS X

    WHERE DATEPART(yyyy, X.[ReferralRequest_ReceivedDate])= @year AND 
          DATEPART(mm, X.[ReferralRequest_ReceivedDate])= CAST(@cnt AS VARCHAR(4)) 
      GROUP BY X.[CMv2_Pseudo_Number]

    -- Contacts
    DROP TABLE IF EXISTS #_tmp_Cont
    SELECT X.[CMv2_Pseudo_Number] AS [CMv2_Pseudo_Number], COUNT(*) AS Cont_Total, SUM([MH01]) AS C_SType01, 
          SUM([MH02]) AS C_SType02, SUM([MH03]) AS C_SType03,
          SUM([MH04]) AS C_SType04, SUM([MH05]) AS C_SType05,
          SUM([MH06]) AS C_SType06, SUM([MH07]) AS C_SType07,
          SUM([MH08]) AS C_SType08, SUM([MH09]) AS C_SType09,
          SUM([MH10]) AS C_SType10, SUM([MH11]) AS C_SType11,
          SUM([MH12]) AS C_SType12, SUM([MH13]) AS C_SType13,
          SUM([MH14]) AS C_SType14, SUM([MH15]) AS C_SType15,
          SUM([MH16]) AS C_SType16, SUM([MH17]) AS C_SType17,
          SUM([MH18]) AS C_SType18, SUM([MH19]) AS C_SType19,
          SUM([MH20]) AS C_SType20, SUM([MH21]) AS C_SType21,
          SUM([MH22]) AS C_SType22, SUM([MH23]) AS C_SType23,
          SUM([MH24]) AS C_SType24, SUM([MH25]) AS C_SType25,
          SUM([MH26]) AS C_SType26, SUM([MH98]) AS C_SType98
    INTO #_tmp_Cont      
    FROM (SELECT A.[CMv2_Pseudo_Number], [Contact_Date], [MH01], 
          [MH02], [MH03], [MH04], [MH05],
          [MH06], [MH07], [MH08], [MH09],
          [MH10], [MH11], [MH12], [MH13],
          [MH14], [MH15], [MH16], [MH17],
          [MH18], [MH19], [MH20], [MH21],
          [MH22], [MH23], [MH24], [MH25],
          [MH26], [MH98]
      FROM [Client_SystemP_RW].[KD_MHSDS_CareContact] AS A
      LEFT JOIN [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide] AS B
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
            Ref_Total, 
            R_SType01, R_SType02, R_SType03, R_SType04, 
            R_SType05, R_SType06, R_SType07, R_SType08, 
            R_SType09, R_SType10, R_SType11, R_SType12, 
            R_SType13, R_SType14, R_SType15, R_SType16, 
            R_SType17, R_SType18, R_SType19, R_SType20, 
            R_SType21, R_SType22, R_SType23, R_SType24,
            R_SType25, R_SType26,
            R_SType98,
            Cont_Total, 
            C_SType01, C_SType02, C_SType03, C_SType04, 
            C_SType05, C_SType06, C_SType07, C_SType08, 
            C_SType09, C_SType10, C_SType11, C_SType12, 
            C_SType13, C_SType14, C_SType15, C_SType16, 
            C_SType17, C_SType18, C_SType19, C_SType20, 
            C_SType21, C_SType22, C_SType23, C_SType24,
            C_SType25, C_SType26,
            C_SType98
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


DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2022]
SELECT * INTO [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2022] FROM #_temp_Output
DROP TABLE IF EXISTS #_temp_Output


-- TEST----------------------------------------------------------------------------------------
SELECT COUNT(*) AS CNT FROM [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2022]
SELECT TStamp, COUNT(*) AS CNT FROM [Client_SystemP_RW].[KD_MHSDS_Referrals_CareContacts_2022]
  GROUP BY TStamp
  ORDER BY TStamp

