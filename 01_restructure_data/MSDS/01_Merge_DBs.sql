/*
Script: 01_Merge_DBs.sql
Description: Prepare Mental Health Services Data Set (MHSDS) tables - Clean/Recode/Linkage processes. 
Dependencies: Read only and Read/Write access to [Client_SystemP] and [Client_SystemP_RW] schemas respectively.
             Tables 
             - [Client_SystemP].[MHSDS_MHS001MPI]
             - [Client_SystemP].[MHSDS_Hist_MHS001MPI]
             - [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo]
             - [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo]
             - [Client_SystemP].[MHSDS_MHS101Referral]
             - [Client_SystemP].[MHSDS_Hist_MHS101Referral]
             - [Client_SystemP].[MHSDS_MHS201CareContact]
             - [Client_SystemP].[MHSDS_Hist_MHS201CareContact]
             - [Client_SystemP].[MHSDS_MHS202CareActivity]
             - [Client_SystemP].[MHSDS_Hist_MHS202CareActivity]
 
Author: Konstantinos Daras (Konstantinos.Daras@liverpool.ac.uk)
Date: September 2022
Notes:
  - Retrieving the latest events is not available for Historic MHSDS data by using the [DerIsLatest]/[UniqueSubmissionID] columns
    Only available for events post 01-07-2020.
    A different approach have been used based on incremental numbers of the latest Financial date 
    ([Der_Financial_Year],[Der_Financial_Month]) partitioned by [Der_Person_ID] + other columns depending on the relevant table


TODO: 
 [DONE] Merge/Clean/linkage of MHS001MPI table
 [DONE] Merge/Clean/linkage of MHS102ServiceTypeReferredTo table
 [DONE] Merge/Clean/linkage of MHS101Referral table  
 [DONE] Merge/Clean/linkage of MHS201CareContact table
 [DONE] Merge/Clean/linkage of MHS202CareActivity table
 
 LATEST OUTPUTS: 03 May 2023 - Referrals up to 2023-02-28 - Contacts up to 2023-02-28

-------------------------------------------------------------------------------------------------------------
This software is released under the GNU GENERAL PUBLIC license. See the LICENSE file for details.

THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. 

IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You acknowledge and agree that the use of this software is at your own risk, and the authors disclaim 
any and all liability for any direct, indirect, incidental, consequential, or special damages or losses 
that may result from the use or inability to use the software.
-------------------------------------------------------------------------------------------------------------

*/

---------------------------------
--- Archive tables
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_ref_MHSDS_PersonID_CMPseudo]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_ref_MHSDS_PersonID_CMPseudo] FROM [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_ref_MHSDS_TeamTypeReferredTo_withGroups]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_ref_MHSDS_TeamTypeReferredTo_withGroups] FROM [Client_SystemP_RW].[KD_ref_MHSDS_TeamTypeReferredTo_withGroups]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_CareActivity]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_CareActivity] FROM [Client_SystemP_RW].[KD_MHSDS_CareActivity]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_CareContact]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_CareContact] FROM [Client_SystemP_RW].[KD_MHSDS_CareContact]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_GroupTypeReferredTo]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_GroupTypeReferredTo] FROM [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_GroupTypeReferredTo_Wide]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_GroupTypeReferredTo_Wide] FROM [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_Referral]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_Referral] FROM [Client_SystemP_RW].[KD_MHSDS_Referral]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_ServiceTypeReferredTo]
SELECT * INTO [Client_SystemP_RW].[ARCH_May2023_KD_MHSDS_ServiceTypeReferredTo] FROM [Client_SystemP_RW].[KD_MHSDS_ServiceTypeReferredTo]

---------------------------------

---------------------------------
-- MPI table - Unique [Der_Person_ID]
---------------------------------

-- MPI table [MHSDS_MHS001MPI]
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp1
SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID],[CMv2_Pseudo_Number]
INTO #_temp_PersonID_CMv2Pseudo_lkp1
FROM
	(SELECT [Der_Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID]
        ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID] ORDER BY [Der_Person_ID], [FDate] DESC) AS RowNum
        ,C.[FDate]
	FROM
		(SELECT [Der_Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
        ,CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		from [Client_SystemP].[MHSDS_MHS001MPI]
        WHERE ([Der_Person_ID] IS NOT NULL) AND ([CMv2_Pseudo_Number] IS NOT NULL)
		) as C
	) as D
WHERE (RowNum<2) 


-- MPI table [MHSDS_Hist_MHS001MPI]
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp2
SELECT [Der_Person_ID],[CMv2_Pseudo_Number]
INTO #_temp_PersonID_CMv2Pseudo_lkp2
FROM
	(SELECT [Der_Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID]
        ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID] ORDER BY [Der_Person_ID], [FDate] DESC) AS RowNum
        ,C.[FDate]
	FROM
		(SELECT TRIM(Der_Person_ID) AS[Der_Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Reconstruct Financial date from [Z_FISCALYEAR] and [Z_FISCALMONTH]
        ,CAST(CONCAT(SUBSTRING([z_FiscalYear],1,4),'-',RIGHT('00'+[z_FiscalMonth],2),'-01') as date) AS FDate
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI]
        WHERE ([Der_Person_ID] IS NOT NULL) AND ([CMv2_Pseudo_Number] IS NOT NULL)
		) as C
	) as D
WHERE (RowNum<2) 


-- MPI table - Merge temporary tables
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
SELECT * INTO [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] FROM #_temp_PersonID_CMv2Pseudo_lkp1
INSERT INTO [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] SELECT * FROM #_temp_PersonID_CMv2Pseudo_lkp2

-- Remove duplicates by [Der_Person_ID],[CMv2_Pseudo_Number]
DROP TABLE IF EXISTS #_temp001
SELECT [Der_Person_ID],
       [CMv2_Pseudo_Number]
 INTO #_temp001
 FROM [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] 
 GROUP BY [Der_Person_ID],[CMv2_Pseudo_Number]

DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_ServiceTypeReferredTo]
SELECT * INTO [Client_SystemP_RW].[KD_CSDS_ServiceTypeReferredTo] FROM #_temp001

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp1
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp2


---------------------------------------------------------
-- MHS102ServiceTypeReferredTo table - Clean/Merge tables
-- DEPENDENCIES: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
--              [Client_SystemP_RW].[KD_ref_MHSDS_TeamTypeReferredTo_withGroups]
---------------------------------------------------------

-- MHS102ServiceTypeReferredTo table - [MHSDS_MHS102ServiceTypeReferredTo]
-- 
DROP TABLE IF EXISTS #_temp_RefType1
SELECT [Der_Person_ID], [Unique_ServiceRequestID], [TeamType]
INTO #_temp_RefType1
FROM
	(SELECT [Der_Person_ID], [Unique_ServiceRequestID], [TeamType] 
        ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID], [Unique_ServiceRequestID], [TeamType] 
                           -- Incremental number based on latest Financial date partitioned by 
                           -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
                           ORDER BY [Der_Person_ID], [Unique_ServiceRequestID], [TeamType],[FDate] DESC) 
                      AS RowNum 
        ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            [ServTeamTypeRefToMH] AS [TeamType],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo]
        WHERE ([Der_Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([UniqServReqID] IS NOT NULL) AND         -- Exclude NULL values
              ([UniqServReqID] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2) 

-- Link reference tables: [Client_SystemP_RW].[KD_ref_PersonID_CMv2Pseudo]
--                        [Client_SystemP_RW].[KD_ref_TeamTypeReferredTo]
DROP TABLE IF EXISTS #_temp_RefType2
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [A].[TeamType] AS [TeamType],
       CASE WHEN [C].[GroupCode]  IS NULL THEN 'MH98' ELSE [C].[GroupCode] END AS [GroupType]
    INTO #_temp_RefType2
		FROM #_temp_RefType1 AS A
		LEFT JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			ON A.Der_Person_ID = B.Der_Person_ID
    LEFT JOIN [Client_SystemP_RW].[KD_ref_MHSDS_TeamTypeReferredTo_withGroups] AS C
      ON A.TeamType = C.TeamType
    WHERE CMv2_Pseudo_Number IS NOT NULL

DROP TABLE IF EXISTS #_temp_RefType1


-- MHS102ServiceTypeReferredTo table - [MHSDS_Hist_MHS102ServiceTypeReferredTo]
-- 
DROP TABLE IF EXISTS #_temp_RefType3
SELECT [Der_Person_ID], [Unique_ServiceRequestID], [TeamType]
INTO #_temp_RefType3
FROM
	(SELECT [Der_Person_ID], [Unique_ServiceRequestID], [TeamType] AS [TeamType]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
        ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID], [Unique_ServiceRequestID], [TeamType] 
                           ORDER BY [Der_Person_ID], [Unique_ServiceRequestID], [TeamType],[FDate] DESC) 
                      AS RowNum 
        ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in UNIQUESERVICEREQUESTIDENTIFIER column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            -- Recode codes related to missing/uknown values
            CASE WHEN [ServTeamTypeRefToMH]  = '656' THEN 'MH98'
                 WHEN [ServTeamTypeRefToMH]  = 'CHA' THEN 'MH98'    
                 WHEN [ServTeamTypeRefToMH]  = 'XXX' THEN 'MH98'
                 WHEN [ServTeamTypeRefToMH]  = '000' THEN 'MH98'    
                 WHEN [ServTeamTypeRefToMH]  = '999' THEN 'MH98' 
                 WHEN [ServTeamTypeRefToMH]  = 'ZZZ' THEN 'MH98'
                 WHEN [ServTeamTypeRefToMH]  = 'NSP' THEN 'MH98'    
            ELSE [ServTeamTypeRefToMH] END AS [TeamType],
            -- Reconstruct Financial date from [Z_FISCALYEAR] and [Z_FISCALMONTH]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo]
        WHERE ([Der_Person_ID] IS NOT NULL) AND 
              ([UniqServReqID] IS NOT NULL) AND
              ([UniqServReqID] NOT LIKE '%NHSNOREM%')
		) AS C
	) AS D
WHERE (RowNum<2) 


-- Link reference tables: [Client_SystemP_RW].[KD_ref_PersonID_CMv2Pseudo]
--                        [Client_SystemP_RW].[KD_ref_TeamTypeReferredTo]
DROP TABLE IF EXISTS #_temp_RefType4
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [A].[TeamType] AS [TeamType],
       CASE WHEN [C].[GroupCode]  IS NULL THEN 'MH98' ELSE [C].[GroupCode] END AS [GroupType]
    INTO #_temp_RefType4
		FROM #_temp_RefType3 AS A
		INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B
			ON A.Der_Person_ID = B.Der_Person_ID
    LEFT OUTER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_TeamTypeReferredTo_withGroups] AS C
      ON A.TeamType = C.TeamType
    WHERE CMv2_Pseudo_Number IS NOT NULL

DROP TABLE IF EXISTS #_temp_RefType3


-- Merge temporary tables 
DROP TABLE IF EXISTS #_temp_RefType
CREATE TABLE #_temp_RefType
(
  CMv2_Pseudo_Number VARCHAR(100),
  Unique_ServiceRequestID VARCHAR(100),
  TeamType VARCHAR(10),
  GroupType VARCHAR(10)
)
INSERT INTO #_temp_RefType (CMv2_Pseudo_Number, Unique_ServiceRequestID, TeamType, GroupType)
   SELECT * FROM #_temp_RefType2 
   UNION ALL
   SELECT * FROM #_temp_RefType4

-- Remove duplicates by [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo]
SELECT [CMv2_Pseudo_Number],
       [Unique_ServiceRequestID],
       [GroupType]
 INTO [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo] 
 FROM #_temp_RefType
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]  

 -- Remove duplicates by [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[TeamType]
 DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_ServiceTypeReferredTo]
SELECT [CMv2_Pseudo_Number],
       [Unique_ServiceRequestID],
       [TeamType]
 INTO [Client_SystemP_RW].[KD_MHSDS_ServiceTypeReferredTo] 
 FROM #_temp_RefType
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[TeamType]  


-- Pivot table - Wide version
/*
MH<number> codes: description
-[MH01]: Asylum
-[MH02]: Autism
-[MH03]: Community
-[MH04]: Community Organic
-[MH05]: Crisis
-[MH06]: Eating
-[MH07]: Education
-[MH08]: Gambling
-[MH09]: Gen. Psychiatry
-[MH10]: Judicial
-[MH11]: LAC
-[MH12]: Learning Community
-[MH13]: Learning Forensic
-[MH14]: Liaison
-[MH15]: Neurodevelopment
-[MH16]: Other
-[MH17]: Perinatal Parenting
-[MH18]: Personality
-[MH19]: Primary Care
-[MH20]: Psychological non IAPT
-[MH21]: Psychosis Early
-[MH22]: Roughsleeping
-[MH23]: Severe
-[MH24]: SP Access
-[MH25]: Substance
-[MH26]: Youth Offend
*/

SELECT  [CMv2_Pseudo_Number],
        [Unique_ServiceRequestID],
        [MH01],
        [MH02],
        [MH03],
        [MH04],
        [MH05],
        [MH06],
        [MH07],
        [MH08],
        [MH09],
        [MH10],
        [MH11],
        [MH12],
        [MH13],
        [MH14],
        [MH15],
        [MH16],
        [MH17],
        [MH18],
        [MH19],
        [MH20],
        [MH21],
        [MH22],
        [MH23],
        [MH24],
        [MH25],
        [MH26], 
        [MH98] 
INTO #_temp_RefType_wide
FROM
(SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]
   FROM [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo]) AS S
 PIVOT (COUNT([GroupType]) FOR GroupType IN ([MH01],[MH02],[MH03],[MH04],[MH05],[MH06],[MH07],[MH08],[MH09],[MH10],
                                             [MH11],[MH12],[MH13],[MH14],[MH15],[MH16],[MH17],[MH18],[MH19],[MH20],
                                             [MH21],[MH22],[MH23],[MH24],[MH25],[MH26],[MH98])) AS T

-- Save wide table to [Client_SystemP_RW]
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide]
SELECT * INTO [Client_SystemP_RW].[KD_MHSDS_GroupTypeReferredTo_Wide] FROM #_temp_RefType_wide

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_RefType
DROP TABLE IF EXISTS #_temp_RefType2
DROP TABLE IF EXISTS #_temp_RefType4
DROP TABLE IF EXISTS #_temp_RefType_wide


-----------------------------------------------------------------
-- MHS101Referral table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_PersonID_CMv2Pseudo]
-----------------------------------------------------------------

-- MHS101Referral table - [MHSDS_MHS101Referral]
SELECT [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
INTO #_temp_Ref1
FROM
	(SELECT [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
          [SourceOfReferral], [PrimaryReferralReason]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate] 
                           ORDER BY [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            [ReferralRequestReceivedDate] AS [ReferralRequest_ReceivedDate],
            [SourceOfReferralMH] AS [SourceOfReferral],
            [PrimReasonReferralMH] AS [PrimaryReferralReason],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_MHS101Referral]
        WHERE ([Der_Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([UniqServReqID] IS NOT NULL) AND         -- Exclude NULL values
              ([UniqServReqID] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2)                

-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason] 
  INTO #_temp_Ref2
	FROM #_temp_Ref1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID  

-- MHS101Referral table - [MHSDS_Hist_MHS101Referral]
DROP TABLE IF EXISTS #_temp_Ref3
SELECT [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
INTO #_temp_Ref3
FROM
	(SELECT [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
          [SourceOfReferral], [PrimaryReferralReason]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate] 
                           ORDER BY [Der_Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            [ReferralRequestReceivedDate] AS [ReferralRequest_ReceivedDate],
            [SourceOfReferralMH] AS [SourceOfReferral],
            [PrimReasonReferralMH] AS [PrimaryReferralReason],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_Hist_MHS101Referral]
        WHERE ([Der_Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([UniqServReqID] IS NOT NULL) AND         -- Exclude NULL values
              ([UniqServReqID] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2)                

-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason] 
  INTO #_temp_Ref4
	FROM #_temp_Ref3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID

-- Merge temporary tables 
SELECT * INTO #_temp_Ref FROM #_temp_Ref2
INSERT INTO #_temp_Ref SELECT * FROM #_temp_Ref4 


-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_Referral] 
SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
 INTO [Client_SystemP_RW].[KD_MHSDS_Referral] 
 FROM #_temp_Ref
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
          [SourceOfReferral], [PrimaryReferralReason]  

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_Ref
DROP TABLE IF EXISTS #_temp_Ref1
DROP TABLE IF EXISTS #_temp_Ref2
DROP TABLE IF EXISTS #_temp_Ref3
DROP TABLE IF EXISTS #_temp_Ref4

-----------------------------------------------------------------
-- MHS201CareContact table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-----------------------------------------------------------------

-- MHS201CareContact table - [MHSDS_MHS201CareContact]
SELECT [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
INTO #_temp_CCont1
FROM
	(SELECT [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
        -- Incremental number based on latest Financial date partitioned by     [AttendOrNot],
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
                           ORDER BY [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            [UniqCareContID]AS [Unique_CareContactID],
            [CareContDate] AS[Contact_Date],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_MHS201CareContact]
        WHERE ([Der_Person_ID] IS NOT NULL) AND             -- Exclude NULL values
              ([UniqServReqID] IS NOT NULL) AND             -- Exclude NULL values
              ([UniqServReqID] NOT LIKE '%NHSNOREM%') AND   -- Exclude 'NHSNOREM' values
              ([AttendOrDNACode] IN ('5','6') OR OrgIDProv='RY2')    -- Keep only Attended patients 
		) AS C
	) AS D
WHERE (RowNum<2)                

-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
  INTO #_temp_CCont2
	FROM #_temp_CCont1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID

-- MHS201CareContact table - [MHSDS_Hist_MHS201CareContact]
SELECT [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
INTO #_temp_CCont3
FROM
	(SELECT [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
                           ORDER BY [Der_Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UniqServReqID] LIKE '%|%' 
                  THEN LEFT([UniqServReqID] , CHARINDEX('|',[UniqServReqID] ) -1) 
            ELSE [UniqServReqID] END AS [Unique_ServiceRequestID],
            [UniqCareContID] AS [Unique_CareContactID],
            [CareContDate] AS [Contact_Date],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_Hist_MHS201CareContact]
        WHERE ([Der_Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([UniqServReqID] IS NOT NULL) AND              -- Exclude NULL values
              ([UniqServReqID] NOT LIKE '%NHSNOREM%') AND    -- Exclude 'NHSNOREM' values
              ([AttendOrDNACode] IN ('5','6') OR OrgCodeProv='RY2')  -- Keep only Attended patients 
		) AS C
	) AS D
WHERE (RowNum<2)                

-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
  INTO #_temp_CCont4
	FROM #_temp_CCont3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID

-- Merge temporary tables 
SELECT * INTO #_temp_CCont FROM #_temp_CCont2
INSERT INTO #_temp_CCont SELECT * FROM #_temp_CCont4 

-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_CareContact] 
SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
 INTO [Client_SystemP_RW].[KD_MHSDS_CareContact] 
 FROM #_temp_CCont
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]  

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_CCont
DROP TABLE IF EXISTS #_temp_CCont1
DROP TABLE IF EXISTS #_temp_CCont2
DROP TABLE IF EXISTS #_temp_CCont3
DROP TABLE IF EXISTS #_temp_CCont4
-----------------------------------------------------------------
-- MHS202CareActivity table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-----------------------------------------------------------------

-- MHS202CareActivity table - [MHSDS_MHS202CareActivity]
SELECT [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
INTO #_temp_CAct1
FROM
	(SELECT [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
        -- Incremental number based on latest Financial date partitioned by     
        -- [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID] 
                           ORDER BY [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            [UniqCareContID]AS [Unique_CareContactID],
            [UniqCareActID] AS [Unique_CareActivityID],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_MHS202CareActivity]
        WHERE ([Der_Person_ID] IS NOT NULL) AND              -- Exclude NULL values
              ([UniqCareContID] IS NOT NULL) AND             -- Exclude NULL values
              ([UniqCareActID] NOT LIKE '%NHSNOREM%') AND    -- Exclude 'NHSNOREM' values
              ([UniqCareActID] IS NOT NULL)                  -- Exclude NULL values
		) AS C
	) AS D
WHERE (RowNum<2)                


-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
  INTO #_temp_CAct2
	FROM #_temp_CAct1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID

-- MHS202CareActivity table - [MHSDS_Hist_MHS202CareActivity]
SELECT [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
INTO #_temp_CAct3
FROM
	(SELECT [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Der_Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID] 
                           ORDER BY [Der_Person_ID],[Unique_CareContactID],[Unique_CareActivityID],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Der_Person_ID]) AS [Der_Person_ID], 
            [UniqCareContID] AS [Unique_CareContactID],
            [UniqCareActID] AS [Unique_CareActivityID],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[MHSDS_Hist_MHS202CareActivity]
        WHERE ([Der_Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([UniqCareContID] IS NOT NULL) AND                 -- Exclude NULL values
              ([UniqCareActID] NOT LIKE '%NHSNOREM%') AND      -- Exclude 'NHSNOREM' values
              ([UniqCareActID] IS NOT NULL)                    -- Exclude NULL values
		) AS C
	) AS D
WHERE (RowNum<2)                


-- Link reference tables: [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
  INTO #_temp_CAct4
	FROM #_temp_CAct3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_MHSDS_PersonID_CMPseudo] AS B  
			    ON A.Der_Person_ID = B.Der_Person_ID


-- Merge temporary tables 
SELECT * INTO #_temp_CAct FROM #_temp_CAct2
INSERT INTO #_temp_CAct SELECT * FROM #_temp_CAct4 

-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_MHSDS_CareActivity]
SELECT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
 INTO [Client_SystemP_RW].[KD_MHSDS_CareActivity] 
 FROM #_temp_CAct
 GROUP BY [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID] -- 4,535,165

-- DROP temporary tables
DROP TABLE IF EXISTS #_temp_CAct
DROP TABLE IF EXISTS #_temp_CAct1
DROP TABLE IF EXISTS #_temp_CAct2
DROP TABLE IF EXISTS #_temp_CAct3
DROP TABLE IF EXISTS #_temp_CAct4



-----------------------------------------------------------------



