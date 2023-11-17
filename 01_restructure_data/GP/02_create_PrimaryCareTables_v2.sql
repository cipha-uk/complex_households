/****** This is derived from Justine Wiltshire script and method ******/
/***    Updates: Author Roberta Piroddi                             ***/
/***    Client_SystemP_RW.RP_ref_groupcodes_terms_2 contains updated codes and condition cluster categories ***/

-------------------------------------------------------------------------------------------------------------------------------------------------
/*CREATE PRIMARY CARE ACTIVTY TABLE*/
-------------------------------------------------------------------------------------------------------------------------------------------------
drop table if exists Client_SystemP_RW.RP101_PCA
create table Client_SystemP_RW.RP101_PCA (
	[Pseudo_NHS_Number] [nvarchar](2000) NULL,
	[Date] [date] NULL,
	[Code] [nvarchar](50) NULL,
	[GroupName] [nvarchar](250) NULL,
	[Value] [float] NULL,
	[Type] [varchar](2) NULL)

-----------------------------------------------
/* looks for CIPHA GP events or encounters with codes in interesting clusters */
-----------------------------------------------

insert into Client_SystemP_RW.RP101_PCA
select P.Pseudo_NHS_Number
	,case when ENEV.Date is null then '1754-09-12' else cast(ENEV.Date as date) end
	,S.ConceptID
	,REF.GroupName
	,max(ENEV.Value)
	,Type
from Client_SystemP.Patient as P
left join 
		(select FK_Patient_ID, FK_Reference_SnomedCT_ID, EventDate as Date, Value, 'EV' as Type
		from Client_SystemP.GP_Events
			union all
		select FK_Patient_ID, FK_Reference_SnomedCT_ID, EncounterDate as Date, '0' as Value, 'EN' as Type
		from Client_SystemP.GP_Encounters
		) as ENEV

	on P.PK_Patient_ID = ENEV.FK_Patient_ID

left join Client_SystemP.Reference_SnomedCT as S
	on S.PK_Reference_SnomedCT_ID = ENEV.FK_Reference_SnomedCT_ID

left join Client_SystemP_RW.RP_ref_groupcodes_terms_2 as REF    --- the snomed and corresponding clusters are specified in this table
	on S.ConceptID = REF.ConceptCode



where P.FK_Reference_Tenancy_ID = 2
	and Pseudo_NHS_Number is not null
	and GroupCode is not null
	and Date>'2004-04-01'
group by P.Pseudo_NHS_Number 
	,case when ENEV.Date is null then '1754-09-12' else cast(ENEV.Date as date) end
	,S.ConceptID
	,REF.GroupName
	,Type

