/***
Build main patient index (MPI) with patients registered at GPs in C&M
***/

/*** This code has been adapted from Justine Wiltshire's code ***/
/*** Updates author: Roberta Piroddi ***/

/***
THIS IS THE MAIN SKELETON OF THE MPI - Main Patient Index
***/


/***
Uses Justine's look up tables for ethnicity and wards
***/

/*
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

drop table if exists Client_SystemP_RW.RP001_MPI

CREATE TABLE Client_SystemP_RW.RP001_MPI (
	Pseudo_NHS_Number NVARCHAR(2000) NOT NULL,
	GPPracticeCode NVARCHAR(6) NULL,
	X_CCG_OF_REGISTRATION VARCHAR(255) NULL,
        X_CCG_OF_RESIDENCE VARCHAR(255) NULL,
	Dob VARCHAR(10) NULL,
	Age INT NULL,
	Sex VARCHAR(1) NULL,
	EthnicGroup VARCHAR(22) NULL,
	EthnicSubGroup VARCHAR(44) NULL,
	InterpreterRequired VARCHAR(1) NULL,
	Deceased NCHAR(1) NULL,
	LSOA NVARCHAR(9) NULL,
	LSOADecile int NULL,
	WardCode varchar(9) NULL,
	WardName varchar(52) NULL,
	LAT float NULL,
	LONG float NULL,
	FrailtyScore float NULL,
	FrailtyLevel nvarchar(8) NULL,
	TotalHousehold int NULL,
	LivingAlone nvarchar(1) NULL,
	LivingWithUnder18 nvarchar(1) NULL,
	UPRNMatch nvarchar(1) NULL)

INSERT INTO Client_SystemP_RW.RP001_MPI
SELECT Pseudo_NHS_Number
	,MAX(case when left(GPPracticeCode,1)='V' then '0' else left(GPPracticeCode,6) end)--v's were only duplicates on practices
	,P.X_CCG_OF_REGISTRATION
    ,P.X_CCG_OF_RESIDENCE
	,Dob
	,cast(datediff(d,cast(Dob+'-15' AS date),getdate())/365.25 AS int)
	,Sex
	,EthnicGroup
	,EthnicSubGroup
	,InterpreterRequired
	,PL.Deceased
	,LSOA_Code
        ,0
	,''
	,''
	,LAT
	,LONG
        ,max(FrailtyScore) as FrailtyScore
	,'' as FrailtyLevel
	,sum(total_household_population)
	,living_alone_flag
	,living_with_under_18_flag
	,case when U.Der_Pseudo_NHS_Number is NULL then 'N' else 'Y' end AS UPRNMatch
FROM Client_SystemP.Patient AS P
LEFT JOIN 
	Client_SystemP.Patient_Link AS PL
	on P.FK_Patient_Link_ID = PL.PK_Patient_Link_ID
LEFT JOIN 
	Client_SystemP_RW.JWRefEthnicLookUp AS E
	on PL.NHS_EthnicCategory = E.EthnicCode
LEFT OUTER JOIN 
	[Client_SystemP].[PDS_UPRN_Indicators] AS U
	on P.Pseudo_NHS_Number=U.Der_Pseudo_NHS_Number
WHERE 
	FK_Reference_Tenancy_ID = 2                  -- GP data
	--and P.Deleted = 'N'                            -- Current data
	--and PL.Deceased <> 'Y'                         -- Not marked as deceased
	and Pseudo_NHS_Number is not NULL	
GROUP BY 
	Pseudo_NHS_Number
	,Dob
	,cast(datediff(d,cast(Dob+'-15' AS date),getdate())/365.25 AS int)
	,P.X_CCG_OF_REGISTRATION
        ,P.X_CCG_OF_RESIDENCE
	,Sex
	,EthnicGroup
	,EthnicSubGroup
	,InterpreterRequired
	,Deceased
	,LSOA_Code
	,LAT
	,LONG
        ,living_alone_flag
	,living_with_under_18_flag
	,case when U.Der_Pseudo_NHS_Number is NULL then 'N' else 'Y' end

/*
UPDATE FOR ETHNICITY

Use SUS[_ECDS, APCS, OPA] to update ethnicity value in MPI table if it is 'Not Stated' or NULL
*/

DROP TABLE IF EXISTS #ethnic

SELECT 
	Pseudo_NHS_Number
	,Ethnic
	,EthnicSubGroup
	,EthnicGroup
INTO #ethnic
FROM
	(SELECT 
		Pseudo_NHS_Number
		,Ethnic
		,MaxDate
		,row_number() OVER (PARTITION BY Pseudo_NHS_Number  ORDER BY Pseudo_NHS_Number , MaxDate desc) as RowNum
	FROM
		( 
		-- Most recent pNHS#/Ethnic value for ECDS/APCS/OPA where EthnicSubGroup missing from MPI.
		SELECT 
			Pseudo_NHS_Number
			,Ethnic_Category as Ethnic
			,max(Arrival_Date) as MaxDate
		FROM 
			Client_SystemP.SUS_ECDS as A
		INNER JOIN 
			Client_SystemP_RW.RP001_MPI as M
			ON A.Cipha_Pseudo_Number=M.Pseudo_NHS_Number
		WHERE 
			Ethnic_Category in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S')
			AND (M.EthnicSubGroup ='Not Stated' or M.EthnicSubGroup is null)
		GROUP BY 
			Pseudo_NHS_Number
			,Ethnic_Category

		UNION ALL

		SELECT 
			Pseudo_NHS_Number
			,Ethnic_Group as Ethnic
			,max(Admission_Date) as MaxDate
		FROM 
			[Client_SystemP].[SUS_APCS] as A
		INNER JOIN 
			Client_SystemP_RW.RP001_MPI as M
			ON A.Cipha_Pseudo_Number=M.Pseudo_NHS_Number
		WHERE 
			Ethnic_Group in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S')
			AND (M.EthnicSubGroup ='Not Stated' or M.EthnicSubGroup is null)
		GROUP BY 
			Pseudo_NHS_Number
			,Ethnic_Group

		UNION ALL

		SELECT 
			Pseudo_NHS_Number
			,Ethnic_Category as Ethnic
			,max(Appointment_Date) as MaxDate
		FROM 
			[Client_SystemP].[SUS_OPA] as A
		INNER JOIN 
			Client_SystemP_RW.RP001_MPI as M
			ON A.Cipha_Pseudo_Number=M.Pseudo_NHS_Number
		WHERE 
			Ethnic_Category in ('A','B','C','D','E','F','G','H','J','K','L','M','N','P','R','S')
			AND (M.EthnicSubGroup ='Not Stated' or M.EthnicSubGroup is null)
		GROUP BY 
			Pseudo_NHS_Number
			,Ethnic_Category
		) as A
	) as B
LEFT JOIN 
	Client_SystemP_RW.JWRefEthnicLookUp as E
	ON B.Ethnic = E.EthnicCode
WHERE RowNum=1



UPDATE Client_SystemP_RW.RP001_MPI
	SET 
		Client_SystemP_RW.RP001_MPI.EthnicSubGroup = E.EthnicSubGroup
		,Client_SystemP_RW.RP001_MPI.EthnicGroup = E.EthnicGroup
	FROM 
		Client_SystemP_RW.RP001_MPI as M
	INNER JOIN 
		#ethnic as E
		ON M.Pseudo_NHS_Number = E.Pseudo_NHS_Number
	WHERE 
		M.EthnicSubGroup ='Not Stated' or M.EthnicSubGroup is null



DROP TABLE IF EXISTS #ethnic


/*UPDATE FOR DECILE. DON'T DO EARIER BECAUSE OF MAX ISSUE*/
update Client_SystemP_RW.RP001_MPI
set Client_SystemP_RW.RP001_MPI.LSOADecile = D.IMD_decile
from Client_SystemP_RW.RP001_MPI as M
left join [Client_SystemP_RW].[JWRefIMD] as D
	on M.LSOA = D.LSOA_code_2011

/*UPDATE FOR WARD. DON'T DO EARIER BECAUSE OF MAX ISSUE*/
update Client_SystemP_RW.RP001_MPI
set Client_SystemP_RW.RP001_MPI.WardCode = W.WD21CD
	, Client_SystemP_RW.RP001_MPI.WardName = W.WD21NM
from Client_SystemP_RW.RP001_MPI as M
left join [Client_SystemP_RW].[JWRefLSOAWard] as W
	on M.LSOA = W.LSOA11CD

/*select count(*), sum(case when WardCode is null or WardCode='' then 1 else 0 end) from Client_SystemP_RW.PS1_MPI
select WardCode, count(*) from Client_SystemP_RW.PS1_MPI group by WardCode
select distinct LSOA, WardCode from Client_SystemP_RW.PS1_MPI*/