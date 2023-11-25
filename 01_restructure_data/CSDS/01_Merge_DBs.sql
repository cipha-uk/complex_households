/*
Script: 01_Merge_DBs.sql
Description: Prepare Community Services Data Set (CSDS) tables - Clean/Recode/Linkage processes. 
Depedencies: Read only and Read/Write access to [Client_SystemP] and [Client_SystemP_RW] schemas respectively.
             Tables 
             - [Client_SystemP].[CSDS_CYP001MPI]
             - [Client_SystemP].[CSDS_Hist_CYP001MPI]
             - [Client_SystemP].[CSDS_CYP102ServiceTypeReferredTo]
             - [Client_SystemP].[CSDS_Hist_CYP102ServiceTypeReferredTo]
             - [Client_SystemP].[CSDS_CYP101Referral]
             - [Client_SystemP].[CSDS_Hist_CYP101Referral]
             - [Client_SystemP].[CSDS_CYP201CareContact]
             - [Client_SystemP].[CSDS_Hist_CYP201CareContact]
             - [Client_SystemP].[CSDS_CYP202CareActivity]
             - [Client_SystemP].[CSDS_Hist_CYP202CareActivity]
             - 
             - 
Author: Konstantinos Daras (Konstantinos.Daras@liverpool.ac.uk)
Date: September 2022
Notes:
  - Retrieving the latest events is not available for Historic CSDS data by using the [DerIsLatest]/[UniqueSubmissionID] columns
    Only available for events post 01-07-2020.
    A different approach have been used based on incremental numbers of the latest Financial date 
    ([Der_Financial_Year],[Der_Financial_Month]) partitioned by [Person_ID] + other columns depending on the relevant table
  - [UniqueSubmissionID] values in: [Client_SystemP].[CSDS_CYP201CareContact] table = 4,303 
    [Client_SystemP].[CSDS_CYP001MPI] table = 5,481
    [Client_SystemP].[CSDS_CYP101Referral] table = 5,414
  - 21 Sept 2022: [Cipha_Pseudo_Number] renamed to [CMv2_Pseudo_Number]
  - 27 Sept 2022: Replace 'Cipha' prefix with 'CMv2' prefix 
  - 

TODO: 
 [DONE] Merge/Clean/linkage of CYP001MPI table
 [DONE] Merge/Clean/linkage of CYP102ServiceTypeReferredTo table
 [DONE] Merge/Clean/linkage of CYP101Referral table  
 [DONE] Merge/Clean/linkage of CYP201CareContact table
 [DONE] Merge/Clean/linkage of CYP202CareActivity table
 [PAUSE] Merge/Clean/linkage of CYP612CodedAssessmentContact table

LATEST OUTPUTS: 02 May 2023 - Referrals up to 2023-03-31 - Contacts up to 2023-03-31
                24 Aug 2023 - Referrals up to 2023-07-31 - Contacts up to 2023-07-31            

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
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_PersonID_CMv2Pseudo]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_PersonID_CMv2Pseudo] FROM [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_ChildLookedAfter]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_ChildLookedAfter] FROM [Client_SystemP_RW].[KD_ref_CSDS_ChildLookedAfter]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_TeamTypeReferredTo_withGroups]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_ref_CSDS_TeamTypeReferredTo_withGroups] FROM [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_CareActivity]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_CareActivity] FROM [Client_SystemP_RW].[KD_CSDS_CareActivity]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_CareContact]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_CareContact] FROM [Client_SystemP_RW].[KD_CSDS_CareContact]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_GroupTypeReferredTo]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_GroupTypeReferredTo] FROM [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_GroupTypeReferredTo_Wide]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_GroupTypeReferredTo_Wide] FROM [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_Referral]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_Referral] FROM [Client_SystemP_RW].[KD_CSDS_Referral]
DROP TABLE IF EXISTS [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_ServiceTypeReferredTo]
SELECT * INTO [Client_SystemP_RW].[ARCH_Aug2023_KD_CSDS_ServiceTypeReferredTo] FROM [Client_SystemP_RW].[KD_CSDS_ServiceTypeReferredTo]

---------------------------------


---------------------------------
-- MPI table - Unique [Person_ID]
---------------------------------

-- MPI table [CSDS_CYP001MPI]
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp1
SELECT TRIM([Person_ID]) AS [Person_ID],[CMv2_Pseudo_Number]
INTO #_temp_PersonID_CMv2Pseudo_lkp1
FROM
	(SELECT [Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID]
        ,ROW_NUMBER() OVER(PARTITION BY [Person_ID] ORDER BY [Person_ID], [FDate] DESC) AS RowNum
        ,C.[FDate]
	FROM
		(SELECT [Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
        ,CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		from [Client_SystemP].[CSDS_CYP001MPI]
        WHERE ([Person_ID] IS NOT NULL) AND ([CMv2_Pseudo_Number] IS NOT NULL)
		) as C
	) as D
WHERE (RowNum<2) 


-- MPI table [CSDS_Hist_CYP001MPI]
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp2
SELECT [Person_ID],[CMv2_Pseudo_Number]
INTO #_temp_PersonID_CMv2Pseudo_lkp2
FROM
	(SELECT [Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID]
        ,ROW_NUMBER() OVER(PARTITION BY [Person_ID] ORDER BY [Person_ID], [FDate] DESC) AS RowNum
        ,C.[FDate]
	FROM
		(SELECT TRIM(STR(UNIQUECYPHSID_PATIENT)) AS[Person_ID]
        ,[CMv2_Pseudo_Number]
        -- Reconstruct Financial date from [Z_FISCALYEAR] and [Z_FISCALMONTH]
        ,CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		from [Client_SystemP].[CSDS_Hist_CYP001MPI]
        WHERE ([UNIQUECYPHSID_PATIENT] IS NOT NULL) AND ([CMv2_Pseudo_Number] IS NOT NULL)
		) as C
	) as D
WHERE (RowNum<2) 


-- MPI table - Merge temporary tables
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
SELECT * INTO [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] FROM #_temp_PersonID_CMv2Pseudo_lkp1
INSERT INTO [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] SELECT * FROM #_temp_PersonID_CMv2Pseudo_lkp2

-- Remove duplicates by [Der_Person_ID],[CMv2_Pseudo_Number]
DROP TABLE IF EXISTS #_temp001
SELECT [Person_ID],
       [CMv2_Pseudo_Number]
 INTO #_temp001
 FROM [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] 
 GROUP BY [Person_ID],[CMv2_Pseudo_Number]

DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
SELECT * INTO [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] FROM #_temp001   


-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp1
DROP TABLE IF EXISTS #_temp_PersonID_CMv2Pseudo_lkp2

------------------------------------------------------
-- MPI table table - [ChildLookedAfter_Indicator] flag
------------------------------------------------------

-- MPI table - [CSDS_CYP001MPI]
SELECT [CMv2_Pseudo_Number],
       CASE WHEN [ChildLookedAfter_Indicator]  = 'Y' THEN 1 ELSE 0 END AS [CLA_flag]
  INTO #_temp_CLA_flag1
  FROM [Client_SystemP].[CSDS_CYP001MPI]
  WHERE [ChildLookedAfter_Indicator] = 'Y'
GROUP BY [CMv2_Pseudo_Number],[ChildLookedAfter_Indicator]


-- MPI table - [CSDS_Hist_CYP001MPI]
SELECT [CMv2_Pseudo_Number],
       CASE WHEN [LookedAfterInd]  = 'Y' THEN 1 ELSE 0 END AS [CLA_flag]
  INTO #_temp_CLA_flag2
  FROM [Client_SystemP].[CSDS_Hist_CYP001MPI]
  WHERE [LookedAfterInd] = 'Y'
GROUP BY [CMv2_Pseudo_Number],[LookedAfterInd]


-- MPI table - Merge temporary tables
SELECT * INTO #_temp_CLA_flag FROM #_temp_CLA_flag1
INSERT INTO #_temp_CLA_flag SELECT * FROM #_temp_CLA_flag2 

-- Remove duplicate CMv2 Pseudo Numbers
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_ref_CSDS_ChildLookedAfter]
SELECT * INTO [Client_SystemP_RW].[KD_ref_CSDS_ChildLookedAfter] 
FROM #_temp_CLA_flag
GROUP BY [CMv2_Pseudo_Number],[CLA_flag]   

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_CLA_flag
DROP TABLE IF EXISTS #_temp_CLA_flag1
DROP TABLE IF EXISTS #_temp_CLA_flag2


---------------------------------------------------------
-- CYP102ServiceTypeReferredTo table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
--              [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups]
---------------------------------------------------------

-- CYP102ServiceTypeReferredTo table - [CSDS_CYP102ServiceTypeReferredTo]
-- 
SELECT [Person_ID], [Unique_ServiceRequestID], [TeamType]
INTO #_temp_RefType1
FROM
	(SELECT [Person_ID], [Unique_ServiceRequestID], [TeamType0] AS [TeamType]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
        ,ROW_NUMBER() OVER(PARTITION BY [Person_ID], [Unique_ServiceRequestID], [TeamType0] 
                           ORDER BY [Person_ID], [Unique_ServiceRequestID], [TeamType0],[FDate] DESC) 
                      AS RowNum 
        ,C.[FDate]             
	FROM
		(SELECT TRIM([Person_ID]) AS [Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [Unique_ServiceRequestID] LIKE '%|%' 
                  THEN LEFT([Unique_ServiceRequestID] , CHARINDEX('|',[Unique_ServiceRequestID] ) -1) 
            ELSE [Unique_ServiceRequestID] END AS [Unique_ServiceRequestID],
            -- Recode codes related to missing/uknown values
            CASE WHEN [TeamType]  = '00' THEN '98'
                 WHEN [TeamType]  = '99' THEN '98'    
                 WHEN [TeamType]  = 'NU' THEN '98' 
                 WHEN [TeamType]  = 'xx' THEN '98'
            ELSE [TeamType] END AS [TeamType0],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_CYP102ServiceTypeReferredTo]
        WHERE ([Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([Unique_ServiceRequestID] IS NOT NULL) AND         -- Exclude NULL values
              ([Unique_ServiceRequestID] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2) 


-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
--                        [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups]
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [A].[TeamType] AS [TeamType],
       CASE WHEN [C].[GroupCode]  IS NULL THEN '98' ELSE [C].[GroupCode] END AS [GroupType]
    INTO #_temp_RefType2
		FROM #_temp_RefType1 AS A
		INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			ON A.Person_ID = B.Person_ID
    LEFT JOIN [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups] AS C
      ON A.TeamType = C.TeamType

DROP TABLE IF EXISTS #_temp_RefType1



-- CYP102ServiceTypeReferredTo table - [CSDS_Hist_CYP102ServiceTypeReferredTo]
-- 
SELECT [Person_ID], [Unique_ServiceRequestID], [TeamType]
INTO #_temp_RefType3
FROM
	(SELECT [Person_ID], [Unique_ServiceRequestID], [TeamType0] AS [TeamType]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
        ,ROW_NUMBER() OVER(PARTITION BY [Person_ID], [Unique_ServiceRequestID], [TeamType0] 
                           ORDER BY [Person_ID], [Unique_ServiceRequestID], [TeamType0],[FDate] DESC) 
                      AS RowNum 
        ,C.[FDate]             
	FROM
		(SELECT TRIM(STR([UNIQUECYPHSID_PATIENT])) AS [Person_ID], 
            -- Remove trailing chars after '|' char in UNIQUESERVICEREQUESTIDENTIFIER column
            CASE WHEN [UNIQUESERVICEREQUESTIDENTIFIER] LIKE '%|%' 
                  THEN LEFT([UNIQUESERVICEREQUESTIDENTIFIER] , CHARINDEX('|',[UNIQUESERVICEREQUESTIDENTIFIER] ) -1) 
            ELSE [UNIQUESERVICEREQUESTIDENTIFIER] END AS [Unique_ServiceRequestID],
            -- Recode codes related to missing/uknown values
            CASE WHEN [TeamType]  = '00' THEN '98'
                 WHEN [TeamType]  = '99' THEN '98'    
                 WHEN [TeamType]  = 'NU' THEN '98' 
                 WHEN [TeamType]  = 'xx' THEN '98'
            ELSE [TeamType] END AS [TeamType0],
            -- Reconstruct Financial date from [Z_FISCALYEAR] and [Z_FISCALMONTH]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_Hist_CYP102ServiceTypeReferredTo]
        WHERE ([UNIQUECYPHSID_PATIENT] IS NOT NULL) AND 
              ([UNIQUESERVICEREQUESTIDENTIFIER] IS NOT NULL) AND
              ([UNIQUESERVICEREQUESTIDENTIFIER] NOT LIKE '%NHSNOREM%')
		) AS C
	) AS D
WHERE (RowNum<2) 


-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
--                        [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups]
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [A].[TeamType] AS [TeamType],
       CASE WHEN [C].[GroupCode]  IS NULL THEN '98' ELSE [C].[GroupCode] END AS [GroupType]
    INTO #_temp_RefType4
		FROM #_temp_RefType3 AS A
		INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B
			ON A.Person_ID = B.Person_ID
    LEFT JOIN [Client_SystemP_RW].[KD_ref_CSDS_TeamTypeReferredTo_withGroups] AS C
      ON A.TeamType = C.TeamType

DROP TABLE IF EXISTS #_temp_RefType3

-- Merge temporary tables 
SELECT * INTO #_temp_RefType FROM #_temp_RefType2
INSERT INTO #_temp_RefType SELECT * FROM #_temp_RefType4 


-- Remove duplicates by [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo] 
SELECT [CMv2_Pseudo_Number],
       [Unique_ServiceRequestID],
       CONCAT('T',[GroupType]) AS [GroupType]
 INTO [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo] 
 FROM #_temp_RefType
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]  

-- Remove duplicates by [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[TeamType]
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_ServiceTypeReferredTo]
SELECT [CMv2_Pseudo_Number],
       [Unique_ServiceRequestID],
       [TeamType]
 INTO [Client_SystemP_RW].[KD_CSDS_ServiceTypeReferredTo] 
 FROM #_temp_RefType
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[TeamType] 


-- Pivot table - Wide version
/*
GType<number> codes description
-[GType01]: Allied Health Professionals
-[GType02]: Audiology
-[GType03]: Community rehabilitation
-[GType04]: Community services for children, including nursing
-[GType05]: Health visitors and midwifery
-[GType06]: Medical and dental services 
-[GType07]: Nursing
-[GType08]: Other
-[GType09]: Palliative
-[GType10]: Podiatry
-[GType11]: Single condition community rehabilitation teams
-[GType12]: Wheelchair
-[GType98]: Missing/Uknown
*/

SELECT [CMv2_Pseudo_Number],
       [Unique_ServiceRequestID],
       [T01] AS [GType01], 
       [T02] AS [GType02], 
       [T03] as [GType03], 
       [T04] as [GType04], 
       [T05] as [GType05],
       [T06] as [GType06], 
       [T07] as [GType07], 
       [T08] as [GType08], 
       [T09] as [GType09],
       [T10] as [GType10], 
       [T11] as [GType11], 
       [T12] as [GType12], 
       [T98] as [GType98] 
INTO #_temp_RefType_wide
FROM
(SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[GroupType]
   FROM [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo]) AS S
 PIVOT (COUNT([GroupType]) FOR GroupType IN ([T01],[T02],[T03],[T04],[T05],[T06],[T07],[T08],[T09],[T10],[T11],[T12],[T98])) AS T

-- Save wide table to [Client_SystemP_RW]
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide]
SELECT * INTO [Client_SystemP_RW].[KD_CSDS_GroupTypeReferredTo_Wide] FROM #_temp_RefType_wide

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_RefType
DROP TABLE IF EXISTS #_temp_RefType2
DROP TABLE IF EXISTS #_temp_RefType4
DROP TABLE IF EXISTS #_temp_RefType_wide


-----------------------------------------------------------------
-- CYP101Referral table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-----------------------------------------------------------------

-- CYP101Referral table - [CSDS_CYP101Referral]
SELECT [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
INTO #_temp_Ref1
FROM
	(SELECT [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
          [SourceOfReferral], [PrimaryReferralReason]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate] 
                           ORDER BY [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Person_ID]) AS [Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [Unique_ServiceRequestID] LIKE '%|%' 
                  THEN LEFT([Unique_ServiceRequestID] , CHARINDEX('|',[Unique_ServiceRequestID] ) -1) 
            ELSE [Unique_ServiceRequestID] END AS [Unique_ServiceRequestID],
            [ReferralRequest_ReceivedDate],
            [SourceOfReferral],
            [PrimaryReferralReason],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_CYP101Referral]
        WHERE ([Person_ID] IS NOT NULL) AND                       -- Exclude NULL values
              ([Unique_ServiceRequestID] IS NOT NULL) AND         -- Exclude NULL values
              ([Unique_ServiceRequestID] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2)                


-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason] 
  INTO #_temp_Ref2
	FROM #_temp_Ref1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID

-- CYP101Referral table - [CSDS_Hist_CYP101Referral]
SELECT [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
INTO #_temp_Ref3
FROM
	(SELECT [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
          [SourceOfReferral], [PrimaryReferralReason]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate] 
                           ORDER BY [Person_ID], [Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM(STR([UNIQUECYPHSID_PATIENT])) AS [Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UNIQUESERVICEREQUESTIDENTIFIER] LIKE '%|%' 
                  THEN LEFT([UNIQUESERVICEREQUESTIDENTIFIER] , CHARINDEX('|',[UNIQUESERVICEREQUESTIDENTIFIER] ) -1) 
            ELSE [UNIQUESERVICEREQUESTIDENTIFIER] END AS [Unique_ServiceRequestID],
            [ReferralDate] AS [ReferralRequest_ReceivedDate],
            [ReferralSource] AS [SourceOfReferral],
            [ReferralReason] AS [PrimaryReferralReason],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_Hist_CYP101Referral]
        WHERE ([UNIQUECYPHSID_PATIENT] IS NOT NULL) AND                       -- Exclude NULL values
              ([UNIQUESERVICEREQUESTIDENTIFIER] IS NOT NULL) AND         -- Exclude NULL values
              ([UNIQUESERVICEREQUESTIDENTIFIER] NOT LIKE '%NHSNOREM%')   -- Exclude 'NHSNOREM' values
		) AS C
	) AS D
WHERE (RowNum<2)                


-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason] 
  INTO #_temp_Ref4
	FROM #_temp_Ref3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID


-- Merge temporary tables 
SELECT * INTO #_temp_Ref FROM #_temp_Ref2
INSERT INTO #_temp_Ref SELECT * FROM #_temp_Ref4 


-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_Referral]
SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID], [ReferralRequest_ReceivedDate],
       [SourceOfReferral], [PrimaryReferralReason]
 INTO [Client_SystemP_RW].[KD_CSDS_Referral] 
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
-- CYP201CareContact table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-----------------------------------------------------------------

-- CYP201CareContact table - [CSDS_CYP201CareContact]
SELECT [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
INTO #_temp_CCont1
FROM
	(SELECT [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
        -- Incremental number based on latest Financial date partitioned by     [AttendOrNot],
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
                           ORDER BY [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Person_ID]) AS [Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [Unique_ServiceRequestID] LIKE '%|%' 
                  THEN LEFT([Unique_ServiceRequestID] , CHARINDEX('|',[Unique_ServiceRequestID] ) -1) 
            ELSE [Unique_ServiceRequestID] END AS [Unique_ServiceRequestID],
            [Unique_CareContactID],
            [Contact_Date],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_CYP201CareContact]
        WHERE ([Person_ID] IS NOT NULL) AND                           -- Exclude NULL values
              ([Unique_ServiceRequestID] IS NOT NULL) AND             -- Exclude NULL values
              ([Unique_ServiceRequestID] NOT LIKE '%NHSNOREM%') AND   -- Exclude 'NHSNOREM' values
              ([AttendOrNot] IN ('5','6') OR OrgID_Provider='RY2')    -- Keep only Attended patients 
		) AS C
	) AS D
WHERE (RowNum<2)                


-- DROP TABLE #_temp_CCont1

-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
  INTO #_temp_CCont2
	FROM #_temp_CCont1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID

-- CYP201CareContact table - [CSDS_Hist_CYP201CareContact]
SELECT [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
INTO #_temp_CCont3
FROM
	(SELECT [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
                           ORDER BY [Person_ID],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM(STR([UNIQUECYPHSID_PATIENT])) AS [Person_ID], 
            -- Remove trailing chars after '|' char in Unique_ServiceRequestID column
            CASE WHEN [UNIQUESERVICEREQUESTIDENTIFIER] LIKE '%|%' 
                  THEN LEFT([UNIQUESERVICEREQUESTIDENTIFIER] , CHARINDEX('|',[UNIQUESERVICEREQUESTIDENTIFIER] ) -1) 
            ELSE [UNIQUESERVICEREQUESTIDENTIFIER] END AS [Unique_ServiceRequestID],
            [UNIQUECARECONTACTIDENTIFIER] AS [Unique_CareContactID],
            [CContactDate] AS [Contact_Date],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_Hist_CYP201CareContact]
        WHERE ([UNIQUECYPHSID_PATIENT] IS NOT NULL) AND                       -- Exclude NULL values
              ([UNIQUESERVICEREQUESTIDENTIFIER] IS NOT NULL) AND              -- Exclude NULL values
              ([UNIQUESERVICEREQUESTIDENTIFIER] NOT LIKE '%NHSNOREM%') AND    -- Exclude 'NHSNOREM' values
              ([AttendCode] IN ('5','6') OR ORGANISATIONCODE_PROVIDER='RY2')  -- Keep only Attended patients 
		) AS C
	) AS D
WHERE (RowNum<2)                

-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date] 
  INTO #_temp_CCont4
	FROM #_temp_CCont3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID

-- Merge temporary tables 
SELECT * INTO #_temp_CCont FROM #_temp_CCont2
INSERT INTO #_temp_CCont SELECT * FROM #_temp_CCont4 

-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_CareContact]
SELECT [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]
 INTO [Client_SystemP_RW].[KD_CSDS_CareContact] 
 FROM #_temp_CCont
 GROUP BY [CMv2_Pseudo_Number],[Unique_ServiceRequestID],[Unique_CareContactID],[Contact_Date]  

-- Drop temporary tables if still in database
DROP TABLE IF EXISTS #_temp_CCont
DROP TABLE IF EXISTS #_temp_CCont1
DROP TABLE IF EXISTS #_temp_CCont2
DROP TABLE IF EXISTS #_temp_CCont3
DROP TABLE IF EXISTS #_temp_CCont4
-----------------------------------------------------------------
-- CYP202CareActivity table - Clean/Merge tables
-- DEPEDENCIES: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-----------------------------------------------------------------

-- CYP202CareActivity table - [CSDS_CYP202CareActivity]
SELECT [Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
INTO #_temp_CAct1
FROM
	(SELECT [Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
        -- Incremental number based on latest Financial date partitioned by     
        -- [Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID],[Unique_CareContactID],[Unique_CareActivityID] 
                           ORDER BY [Person_ID],[Unique_CareContactID],[Unique_CareActivityID],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM([Person_ID]) AS [Person_ID], 
            [Unique_CareContactID],
            [Unique_CareActivityID],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Der_Financial_Year],1,4),'-',[Der_Financial_Month],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_CYP202CareActivity]
        WHERE ([Person_ID] IS NOT NULL) AND                        -- Exclude NULL values
              ([Unique_CareContactID] IS NOT NULL) AND             -- Exclude NULL values
              ([Unique_CareActivityID] NOT LIKE '%NHSNOREM%') AND  -- Exclude 'NHSNOREM' values
              ([Unique_CareActivityID] IS NOT NULL)                -- Exclude NULL values
		) AS C
	) AS D
WHERE (RowNum<2)                

-- DROP TABLE #_temp_CAct1

-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
  INTO #_temp_CAct2
	FROM #_temp_CAct1 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID

-- CYP202CareActivity table - [CSDS_Hist_CYP202CareActivity]
SELECT [Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
INTO #_temp_CAct3
FROM
	(SELECT [Person_ID],[Unique_CareContactID],[Unique_CareActivityID]
        -- Incremental number based on latest Financial date partitioned by 
        -- [Person_ID], [Unique_ServiceRequestID], [TeamType0]
          ,ROW_NUMBER() OVER(PARTITION BY [Person_ID],[Unique_CareContactID],[Unique_CareActivityID] 
                           ORDER BY [Person_ID],[Unique_CareContactID],[Unique_CareActivityID],[FDate] DESC) 
                      AS RowNum 
          ,C.[FDate]             
	FROM
		(SELECT TRIM(STR([UNIQUECYPHSID_PATIENT])) AS [Person_ID], 
            [UNIQUECARECONTACTIDENTIFIER] AS [Unique_CareContactID],
            [UNIQUECAREACTIVITYIDENTIFIER] AS [Unique_CareActivityID],
            -- Reconstruct Financial date from [Der_Financial_Year] and [Der_Financial_Month]
            CAST(CONCAT(SUBSTRING([Z_FISCALYEAR],1,4),'-',[Z_FISCALMONTH],'-01') as date) AS FDate
		FROM [Client_SystemP].[CSDS_Hist_CYP202CareActivity]
        WHERE ([UNIQUECYPHSID_PATIENT] IS NOT NULL) AND                       -- Exclude NULL values
              ([UNIQUECARECONTACTIDENTIFIER] IS NOT NULL) AND                 -- Exclude NULL values
              ([UNIQUECAREACTIVITYIDENTIFIER] NOT LIKE '%NHSNOREM%') AND      -- Exclude 'NHSNOREM' values
              ([UNIQUECAREACTIVITYIDENTIFIER] IS NOT NULL)                    -- Exclude NULL values
		) AS C
	) AS D
WHERE (RowNum<2)                


-- Link reference tables: [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo]
-- 
SELECT DISTINCT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
  INTO #_temp_CAct4
	FROM #_temp_CAct3 AS A
	INNER JOIN [Client_SystemP_RW].[KD_ref_CSDS_PersonID_CMv2Pseudo] AS B  
			    ON A.Person_ID = B.Person_ID

-- Merge temporary tables 
SELECT * INTO #_temp_CAct FROM #_temp_CAct2
INSERT INTO #_temp_CAct SELECT * FROM #_temp_CAct4 

-- Remove duplicates 
DROP TABLE IF EXISTS [Client_SystemP_RW].[KD_CSDS_CareActivity] 
SELECT [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID]
 INTO [Client_SystemP_RW].[KD_CSDS_CareActivity] 
 FROM #_temp_CAct
 GROUP BY [CMv2_Pseudo_Number],[Unique_CareContactID],[Unique_CareActivityID] 


-- DROP temporary tables
DROP TABLE IF EXISTS #_temp_CAct
DROP TABLE IF EXISTS #_temp_CAct1
DROP TABLE IF EXISTS #_temp_CAct2
DROP TABLE IF EXISTS #_temp_CAct3
DROP TABLE IF EXISTS #_temp_CAct4

-----------------------------------------------------------------

