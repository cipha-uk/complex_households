/****** This code is based on Justine Wiltshire code
******/

/*** Updates author: Roberta Piroddi  ***/


/****** Script to create an MPI only for the Complex person segment  ******/
/**** Useful to support other work ****/
-------------------------------------------------------------------------------------------------------------------------------------------------
/*CREATE COMPLEX MPI AND SET FLAGS TO ZERO*/
-------------------------------------------------------------------------------------------------------------------------------------------------
drop table if exists Client_SystemP_RW.RP104_Complex
create table Client_SystemP_RW.RP104_Complex (
	[Pseudo_NHS_Number] [nvarchar](2000) NULL,
	[LTPC] int NULL,
	[MH] int NULL,
	[Homeless] int NULL,
	[H_abuse] int NULL,
	[Offender] int NULL,
	[Substance_or_alcohol] int NULL	,
	[Alcohol] int NULL,
	[Substance] int NULL,
	[Freq_AE_attend] int NULL,
	[H_looked_after] int NULL,
	[Complex] int NULL,
	[Complex_cohort_2] int NULL,
	[#_Triggers] int NULL)


insert into Client_SystemP_RW.RP104_Complex

select Pseudo_NHS_Number
	,0 
	,0
	,0
	,0
	,0 
	,0
	,0
	,0
	,0 
	,0
	,0
	,0
	,0
from [Client_SystemP_RW].RP001_MPI

-------------------------------------------------------------------------------------------------------------------------------------------------
/*LTPC*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set LTPC = 1 where Pseudo_NHS_Number in 
	(
	select distinct Der_pseudo_nhsnumber_Traced as ID
	from [Client_SystemP].[Adult_Social_Care] --
	where Event_Start_Date>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2014-04-12'), 102)
		and Primary_Support_Reason = 'Learning Disability Support'
		
		union

	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('E01', 'E02', 'E03', 'E04')

		union
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('E01', 'E02', 'E03', 'E04')

		union

	select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
	where [Epilepsy] = 1 
		or [Diabetes] = 1  
		or [IGR] = 1 
		or [Hypertension] = 1 
		or [COPD] = 1 
		or [Asthma] = 1 
		or [CHD] = 1 
		or [Stroke_TIA] = 1 
		or [PVD] = 1 
		or [MI] = 1 
		or [Angina] = 1 
		or [AF] = 1 
		or [Bladder_cancer] = 1 
		or [Breast_cancer] = 1 
		or [Cervical_cancer] = 1 
		or [Bowel_cancer] = 1 
		or [Prostate_cancer] = 1 
		or [Skin_cancer] = 1 
		or [Other_cancer] = 1 
		or [Dementia] = 1 
		or [Learning_Disabilities] = 1 
		or [Parkinsons_disease] = 1 
		or [Motor_neurone_disease] = 1 
		or [Multiple_sclerosis] = 1 
		or [Osteoporosis] = 1 
		or [Osteoarthritis] = 1  
		or [Rheumatoid_arthritis] = 1 
		or [Ankylosing_spondylitis] = 1 
		or [Spondylitis_and_allied_disorders] = 1  
		or [Lupus] = 1 
		or [Fibromyalgia] = 1 
		or [Gout] = 1  
		or [Reactive_arthritis_septic_arthritis] = 1 
		or [Psoriatic_arthritis] = 1 
		or [Osteomalacia] = 1 
		or [Polymyositis] = 1 
		or [Polymyalgia] = 1  
		or [Sjogrens_syndrome] = 1 
		or [Scleroderma] = 1 
		or [Tendonitis] = 1 
		or [Crohns] = 1  
		or [Coeliac] = 1 
		or [Ulcerative_colitis] = 1 
		or [Inflammatory_bowel_disease] = 1 
		or [Diverticulitis] = 1 
		or [Diverticulosis] = 1 
		or [Barretts_oesophagus] = 1 
		or [Organ_Failure] = 1  		
	)

-------------------------------------------------------------------------------------------------------------------------------------------------
/*MENTAL HEALTH*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set MH = 1 where Pseudo_NHS_Number in 
	(
	select distinct Der_pseudo_nhsnumber_Traced as ID
	from [Client_SystemP].[Adult_Social_Care] 
	where Event_Start_Date>= CONVERT(DATETIME, DATEADD(yyyy, -2, '2020-04-12'), 102)
		and Primary_Support_Reason = 'Mental Health Support'

		union

	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and left(ServTeamTypeRefToMH,1) not in ('B', 'E', 'D')
		and ServTeamTypeRefToMH<>'A15' 

		union
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and left(ServTeamTypeRefToMH,1) not in ('B', 'E', 'D')
		and ServTeamTypeRefToMH<>'A15' 

		union		
		
	select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
	where  [Schizophrenia] = 1 
		or [Bipolar] = 1 
		or [Other_Psychosis] = 1 
		or [Psychotic_disorder] = 1 
		or [Anxiety] = 1 
		or [Depression] = 1
  )

-------------------------------------------------------------------------------------------------------------------------------------------------
/*HOMELESS*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set Homeless = 1 where Pseudo_NHS_Number in 
	(select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
	where Homeless = 1)

-------------------------------------------------------------------------------------------------------------------------------------------------
/*ABUSE*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set H_abuse = 1 where Pseudo_NHS_Number in 
	(select distinct [CMv2_Pseudo_Number] as ID 
	 from [Client_SystemP].[SUS_APCE] as E
	 inner join [Client_SystemP].[SUS_APCE_Diag] as D
		on E.APCE_Ident=D.APCE_Ident
	 where [Admission_Date]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2014-10-31'), 102) 
		and ([Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
			like '%T74%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z614%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z615%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z616%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z622%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z625%')
	)

-------------------------------------------------------------------------------------------------------------------------------------------------
/*OFFENDER*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set Offender = 1 where Pseudo_NHS_Number in 
	(select distinct [CMv2_Pseudo_Number] as ID 
		 from [Client_SystemP].[SUS_APCE] as E
		 inner join [Client_SystemP].[SUS_APCE_Diag] as D
			on E.APCE_Ident=D.APCE_Ident
		 where [Admission_Date]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2014-10-31'), 102) 
			and 
			([Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z650%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z651%'
			or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
				like '%Z652%')
		
		union

	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D02', 'B01', 'B02')

		union
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D02', 'B01', 'B02')
	) 

-------------------------------------------------------------------------------------------------------------------------------------------------
/*SUBSTANCE/ALCOHOL*/
-------------------------------------------------------------------------------------------------------------------------------------------------
update Client_SystemP_RW.RP104_Complex
set Substance_or_alcohol = 1 where Pseudo_NHS_Number in 
	(
	select distinct Der_pseudo_nhsnumber_Traced as ID
	from [Client_SystemP].[Adult_Social_Care]
	where Event_Start_Date>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2014-04-12'), 102)  
		and Primary_Support_Reason = 'Social Support: Substance misuse support'

		union

	select distinct Pseudo_NHS_Number as ID 
	from [Client_SystemP].[GP_Medications] as M
		inner join [Client_SystemP].[Patient] as P
			on P.PK_Patient_ID=M.FK_Patient_ID
	where MedicationDate>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2018-01-01'), 102) 
		and
		([MedicationDescription] like 'Acamprosate%'
			or [MedicationDescription] like 'Campral%'
			or [MedicationDescription] like 'Methadone%' 
			or [MedicationDescription] like 'Physeptone%'
			or [MedicationDescription] like 'Methadose%' 
			or [MedicationDescription] like 'Synastone%' 
			or [MedicationDescription] like 'Methex%'
			or [MedicationDescription] like 'Eptadone%')

		union

	select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
		where [Alcohol_misuse] = 1 	
			or [Psychoactive_substance_misuse] = 1
		
		union	
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D01')

		union
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D01')
	)

-------------------------------------------------------------------------------------------------------------------------------------------------
/*SUBSTANCE*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set Substance = 1 where Pseudo_NHS_Number in 
	(
	select distinct Der_pseudo_nhsnumber_Traced as ID
	from [Client_SystemP].[Adult_Social_Care] --[Analysis].[LCCG].[tbl_SocialCare_Pseudo] 
	where Event_Start_Date>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2014-04-12'), 102)
		and Primary_Support_Reason = 'Social Support: Substance misuse support' 

		union

	select distinct Pseudo_NHS_Number as ID 
	from [Client_SystemP].[GP_Medications] as M
		inner join [Client_SystemP].[Patient] as P
			on P.PK_Patient_ID=M.FK_Patient_ID
	where MedicationDate>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2018-01-01'), 102) 
		and ([MedicationDescription] like 'Methadone%' 
			or [MedicationDescription] like 'Physeptone%'
			or [MedicationDescription] like 'Methadose%' 
			or [MedicationDescription] like 'Synastone%' 
			or [MedicationDescription] like 'Methex%'
			or [MedicationDescription] like 'Eptadone%')

		union

	select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
	where [Psychoactive_substance_misuse] = 1

		union		

	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D01')

		union
		
	select distinct CMv2_Pseudo_Number as ID
		from 
		(select distinct CMv2_Pseudo_Number, Person_ID, Frailty_or_Dementia, Complex
		from [Client_SystemP].[MHSDS_Hist_MHS001MPI] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		inner join Client_SystemP_RW.RP103_Segmentation as M
			on A.CMv2_Pseudo_Number=M.Pseudo_NHS_Number
		where DerIsLatest=1
		) as X
		inner join 
		(select distinct Person_ID, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS101Referral] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as Y
		on X.Person_ID = Y.Person_ID
		inner join 
		(select distinct Person_ID, UniqServReqID, ServTeamTypeRefToMH
		from [Client_SystemP].[MHSDS_Hist_MHS102ServiceTypeReferredTo] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1) as R
		on Y.UniqServReqID=R.UniqServReqID	
		inner join 
		(select Person_ID, CareContDate, UniqServReqID
		from [Client_SystemP].[MHSDS_Hist_MHS201CareContact] as A
		inner join [Client_SystemP].[MHSDS_DerLatestFlag] as B
			on A.UniqSubmissionID = B.UniqSubmissionID
		where DerIsLatest=1
			and attendordnacode in ('5','6')) as Z
		on Y.UniqServReqID = Z.UniqServReqID
	where [CareContDate]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2017-10-28'), 102)
		and ServTeamTypeRefToMH in ('D01')
	) 

-------------------------------------------------------------------------------------------------------------------------------------------------
/*ALCOHOL*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set Alcohol = 1 where Pseudo_NHS_Number in 
	(select distinct Pseudo_NHS_Number as ID 
	from [Client_SystemP].[GP_Medications] as M
		inner join [Client_SystemP].[Patient] as P
			on P.PK_Patient_ID=M.FK_Patient_ID
	where MedicationDate>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2018-01-01'), 102) 
		and ([MedicationDescription] like 'Acamprosate%' 
			or [MedicationDescription] like 'Campral%')
		
		union

	select distinct Pseudo_NHS_Number as ID
	from [Client_SystemP_RW].RP103_Segmentation
	where [Alcohol_misuse] = 1
	)

-------------------------------------------------------------------------------------------------------------------------------------------------
/*FREQUENT A&E*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set Freq_AE_attend = 1 where Pseudo_NHS_Number in 
	(select distinct [CMv2_Pseudo_Number] as ID 
	from [Client_SystemP].[SUS_ECDS] as A
	where Arrival_Date>= CONVERT(DATETIME, DATEADD(yyyy, -2, '2021-01-01'), 102)
		and EC_Department_Type = '01' 
		and EC_AttendanceCategory = '1' 
		--AND (Z_REGISTERED_CCG like '99A%') should exclude i think
			group by [CMv2_Pseudo_Number] 
	having count([CMv2_Pseudo_Number])>=20
	)
  
-------------------------------------------------------------------------------------------------------------------------------------------------
/*LOOKED AFTER*/
-------------------------------------------------------------------------------------------------------------------------------------------------

update Client_SystemP_RW.RP104_Complex
set H_looked_after = 1 where Pseudo_NHS_Number in 
	(select distinct [CMv2_Pseudo_Number] as ID 
	 from [Client_SystemP].[SUS_APCE] as E
	 inner join [Client_SystemP].[SUS_APCE_Diag] as D
		on E.APCE_Ident=D.APCE_Ident
	 where [Admission_Date]>=CONVERT(DATETIME, DATEADD(yyyy, -2, '2013-10-31'), 102) 
		and 
		([Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
			like '%Z611%' 
		or [Primary_Diagnosis_Code]+'|'+[Secondary_Diagnosis_Code_1]+'|'+[Secondary_Diagnosis_Code_2]+'|'+[Secondary_Diagnosis_Code_3]+'|'+[Secondary_Diagnosis_Code_4]+'|'+[Secondary_Diagnosis_Code_5]+'|'+[Secondary_Diagnosis_Code_6]+'|'+[Secondary_Diagnosis_Code_7]+'|'+[Secondary_Diagnosis_Code_8]+'|'+[Secondary_Diagnosis_Code_9]+'|'+[Secondary_Diagnosis_Code_10]+'|'+[Secondary_Diagnosis_Code_11]+'|'+[Secondary_Diagnosis_Code_12]+'|'+[Secondary_Diagnosis_Code_13]+'|'+[Secondary_Diagnosis_Code_14]+'|'+[Secondary_Diagnosis_Code_15]+'|'+[Secondary_Diagnosis_Code_16]+'|'+[Secondary_Diagnosis_Code_17]+'|'+[Secondary_Diagnosis_Code_18]+'|'+[Secondary_Diagnosis_Code_19]+'|'+[Secondary_Diagnosis_Code_20]+'|'+[Secondary_Diagnosis_Code_21]+'|'+[Secondary_Diagnosis_Code_22]+'|'+[Secondary_Diagnosis_Code_23]
			like '%Z622%')
	)

update Client_SystemP_RW.RP104_Complex
set Complex = 1 
where ([LTPC] = 1 and [MH] = 1 and ([Homeless] = 1 or [H_abuse] = 1 or [Offender] = 1 or [Substance_or_alcohol] = 1 or [Freq_AE_attend] = 1 or [H_looked_after] = 1))
	or 
	(([LTPC] <> 1 or [MH] <> 1) and [Homeless]+[H_abuse]+[Offender]+[Substance_or_alcohol]+[Freq_AE_attend]+[H_looked_after]>2)

