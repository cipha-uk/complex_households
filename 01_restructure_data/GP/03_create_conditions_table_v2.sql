/****** Script to create the initial condition table - equiv to PCA_test  ******/
/***         The script is based on Justine Wiltshire's code                        ***/
/*** Updates and modifications author: Roberta Piroddi  ***/

-----------
/*CREATE THE MAX TABLES, THE COMPLICATED ONES*/
/* this script also adds the MIN TABLES using the same method as in Justine Wiltshire */

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

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--ALL DATES FOR EVERY PERSON & GROUP

drop table if exists #MAX_DATE_INTERNAL --- one table with the latest date
select Pseudo_NHS_Number, coalesce(GroupName,'') as GroupName, [Date] as MAX_DATE
into #MAX_DATE_INTERNAL
from Client_SystemP_RW.RP101_PCA
group by Pseudo_NHS_Number, coalesce(GroupName,''), [Date]

--------------------------------------------------------------------------------------------
--1ST MOST RECENT CODE FOUND FOR EVERY PERSON & GROUP

drop table if exists #MAX_CODE_INTERNAL --- one table with the latest code
select distinct B.Pseudo_NHS_Number, B.GroupName, B.Code 
into #MAX_CODE_INTERNAL
from
	(select Pseudo_NHS_Number, coalesce(GroupName, '') as GroupName,  max(Date) as Date
	from Client_SystemP_RW.RP101_PCA
	group by Pseudo_NHS_Number, coalesce(GroupName, '') 
	) as A
inner join Client_SystemP_RW.RP101_PCA as B
on A.Pseudo_NHS_Number=B.Pseudo_NHS_Number
	and A.GroupName=B.GroupName
	and A.date=B.Date

--------------------------------------------------------------------------------------------
--1ST MOST RECENT VALUE FOUND FOR EVERY PERSON & GROUP

drop table if exists #MAX_VALUE_INTERNAL --- one table with the latest value
select distinct B.Pseudo_NHS_Number, B.GroupName, B.Value 
into #MAX_VALUE_INTERNAL
from
	(select Pseudo_NHS_Number, coalesce(GroupName, '') as GroupName,  max(Date) as Date--row_number() OVER (PARTITION BY Pseudo_NHS_Number, GroupName, Code ORDER BY Pseudo_NHS_Number, Date DESC) as RowNum 
	from Client_SystemP_RW.RP101_PCA
	group by Pseudo_NHS_Number, coalesce(GroupName, '') 
	) as A
inner join Client_SystemP_RW.RP101_PCA as B
on A.Pseudo_NHS_Number=B.Pseudo_NHS_Number
	and A.GroupName=B.GroupName
	and A.Date=B.Date

-------------------------------------------------------------------------------------------
drop table if exists #MAX_DATE
select *
into #MAX_DATE
from #MAX_DATE_INTERNAL --src2
pivot
	(max(MAX_DATE)
		for GroupName in (Epilepsy,Diabetes,[Impaired Glucose Regulation],Retinopathy,CKD,Hypertension,COPD,Asthma,CHD,Stroke,TIA,[PVD / PAD],[MI Register],Angina,[Heart Failure],[Atrial Fibrillation],
			[Chronic Liver disease],[Bladder Cancer],[Breast Cancer],[Cervical Cancer],[Bowel Cancer],[Prostate Cancer],[Skin Cancer],[Other Cancers],Schizophrenia,[Bipolar Affective Disorder],
			[Other Psychosis],Dementia,Depression,Anxiety,[Palliative Care Register/End of Life Care Register],[Pulmonary Embolism],[Learning Disabilities],Dysphagia,Autism,
			[Psychoactive Substance Misuse Disorder],[Psychotic Disorder],[Age-related Macular Degeneration],[Primary Open-Angle Glaucoma],Blind,[Partially Sighted],[Hearing Impaired],
			[Neurosis],[Poisoning],[Sprain],[Mental disorder],[Gastro-intestinal disorder],[Frailty],[Cholesterol (non-values)],[HbA1C (non-values) Code],[Microalbuminuria Code],
			[Alcohol Consumption],[Alcohol Status],[Alcohol advice],[Brief Intervention (alcohol)],[JBS Risk Score],[Proteinuria],[Smoking Status],[Pulse Rate],[Pulse Rhythm],[MRC Breathless Scale],[Asthma Severity],
			[Asthma Control Steps],[Heart Failure diagnosed via echocardiogram],[Smoking cessation advice],[Referral to Smoking Cessation Clinic],[DNA Smoking Cessation Clinic],[Exercise Advice],
			[Diet Advice],[Mental Health Care plan],[Referral to Pulmonary rehabilitation],[Pulmonary rehabilitation programme commenced],[Pulmonary rehabilitation programme completed],
			[COPD Self management Plan],[COPD Rescue Pack],[Offered Structured Education (Diabetes)],[Attended Structured Education (Diabetes)],[Completed Structured Education (DIabetes)],
			[Insulin Passport],[Referred to cardiac rehabilitation],[Cardiac rehabilitation declined],[Cardiac rehabilitation],[Cardiac Rehabilitation Completed],[Diabetes review (Annual)],
			[Diabetes review (Other)],[Diabetes Care setting],[Referred to Dietician],[Diabetic foot review],[Diabetic Neuropathy testing],[CHD review],[Medication Review],[Medication Review Declined],
			[COPD Annual Review],[Heart Failure review],[Mental Health Review],[Dementia Review],[Depression review],[Depression screening/questionnaire],[Bowel Screening],
			[Bowel Screening Declined],[NHS Health Checks],[Cervical Screening],[Learning Disabilities Health Assessment],[DNA Bowel cancer screening],[CVD Risk assessment declined],
			[DNA NHS Health Check],[Diabetic Retinal Screening � needs checking],[Cervical cytology exceptions],[Hysterectomy and equivalent ],[Spirometry contraindicated/declined],
			[ACE / A2RA Max Tolerated Dose],[Cholesterol],[HDL Cholesterol],[LDL Cholesterol],[BP Diastolic],[BP Systolic],[BMI],[HbA1C],[eGFR],[FEV1/FVC],[Microalbuminuria (Code)],[Albuminuria (ACR)],
			[Spirometry],[Qrisk Score],[Framingham Score],[Creatinine (All in last 1 year)],[Urine Protein Test],[CHA2DS2 VASC],[SERUM ALBUMIN],[TOTAL BILIRUBIN],[PROTHROMBIN TIME / INR],
			[Chronic pain],[Parkinsons disease],[Multiple sclerosis],[Motor neurone disease],[Respiratory failure],[Kidney failure],[Osteoporosis],[Osteoarthritis],[Rheumatoid arthritis],
			[Ankylosing spondylitis],[Spondylosis and allied disorders],[Lupus],[Fibromyalgia],[Gout],[Reactive Septic arthritis],[Psoriatic arthritis],[Osteomalacia],[Polymyositis],
			[Polymyalgia rheumatica],[Sicca (Sjogrens) syndrome],[Scleroderma],[Tendonitis],[Familial Hypercholesterolaemia],[Crohns disease],[Coeliac disease],[Ulcerative colitis],
			[Inflammatory bowel disease],[Diverticulitis],[Diverticulosis],[Barretts oesophagus],[Physical Disability]
			,[Attention Deficit Hyperactivity Disorder],[Frailty Index],[Lymphoedema],Homeless, Carer, [Asylum Seeker],[Suicide and Self Harm])
	) piv_max 

--------------------------------------------------------------------------------------------
drop table if exists #MAX_CODE
select *
into #MAX_CODE
from #MAX_CODE_INTERNAL --src5
pivot
	(max(Code)
		for GroupName in (Epilepsy,Diabetes,[Impaired Glucose Regulation],Retinopathy,CKD,Hypertension,COPD,Asthma,CHD,Stroke,TIA,[PVD / PAD],[MI Register],Angina,[Heart Failure],[Atrial Fibrillation],
              [Chronic Liver disease],[Bladder Cancer],[Breast Cancer],[Cervical Cancer],[Bowel Cancer],[Prostate Cancer],[Skin Cancer],[Other Cancers],Schizophrenia,[Bipolar Affective Disorder],
              [Other Psychosis],Dementia,Depression,Anxiety,[Palliative Care Register/End of Life Care Register],[Pulmonary Embolism],[Learning Disabilities],Dysphagia,Autism,
              [Psychoactive Substance Misuse Disorder],[Psychotic Disorder],[Age-related Macular Degeneration],[Primary Open-Angle Glaucoma],Blind,[Partially Sighted],[Hearing Impaired],
              [Neurosis],[Poisoning],[Sprain],[Mental disorder],[Gastro-intestinal disorder],[Frailty],[Cholesterol (non-values)],[HbA1C (non-values) Code],[Microalbuminuria Code],
              [Alcohol Consumption],[Alcohol Status],[Alcohol advice],[Brief Intervention (alcohol)],[JBS Risk Score],[Proteinuria],[Smoking Status],[Pulse Rate],[Pulse Rhythm],[MRC Breathless Scale],[Asthma Severity],
              [Asthma Control Steps],[Heart Failure diagnosed via echocardiogram],[Smoking cessation advice],[Referral to Smoking Cessation Clinic],[DNA Smoking Cessation Clinic],[Exercise Advice],
              [Diet Advice],[Mental Health Care plan],[Referral to Pulmonary rehabilitation],[Pulmonary rehabilitation programme commenced],[Pulmonary rehabilitation programme completed],
              [COPD Self management Plan],[COPD Rescue Pack],[Offered Structured Education (Diabetes)],[Attended Structured Education (Diabetes)],[Completed Structured Education (DIabetes)],
              [Insulin Passport],[Referred to cardiac rehabilitation],[Cardiac rehabilitation declined],[Cardiac rehabilitation],[Cardiac Rehabilitation Completed],[Diabetes review (Annual)],
              [Diabetes review (Other)],[Diabetes Care setting],[Referred to Dietician],[Diabetic foot review],[Diabetic Neuropathy testing],[CHD review],[Medication Review],[Medication Review Declined],
              [COPD Annual Review],[Heart Failure review],[Mental Health Review],[Dementia Review],[Depression review],[Depression screening/questionnaire],[Bowel Screening],
              [Bowel Screening Declined],[NHS Health Checks],[Cervical Screening],[Learning Disabilities Health Assessment],[DNA Bowel cancer screening],[CVD Risk assessment declined],
              [DNA NHS Health Check],[Diabetic Retinal Screening � needs checking],[Cervical cytology exceptions],[Hysterectomy and equivalent ],[Spirometry contraindicated/declined],
              [ACE / A2RA Max Tolerated Dose],[Cholesterol],[HDL Cholesterol],[LDL Cholesterol],[BP Diastolic],[BP Systolic],[BMI],[HbA1C],[eGFR],[FEV1/FVC],[Microalbuminuria (Code)],[Albuminuria (ACR)],
              [Spirometry],[Qrisk Score],[Framingham Score],[Creatinine (All in last 1 year)],[Urine Protein Test],[Chronic pain],[Parkinsons disease],[Multiple sclerosis],[Motor neurone disease],
              [Respiratory failure],[Kidney failure],[Osteoporosis],[Osteoarthritis],[Rheumatoid arthritis],[Ankylosing spondylitis],[Spondylosis and allied disorders],[Lupus],[Fibromyalgia],
              [Gout],[Reactive Septic arthritis],[Psoriatic arthritis],[Osteomalacia],[Polymyositis],[Polymyalgia rheumatica],[Sicca (Sjogrens) syndrome],[Scleroderma],[Tendonitis],[Familial Hypercholesterolaemia],
              [Crohns disease],[Coeliac disease],[Ulcerative colitis],[Inflammatory bowel disease],[Diverticulitis],[Diverticulosis],[Barretts oesophagus],[Physical Disability]
			  ,[Attention Deficit Hyperactivity Disorder],[Frailty Index],[Lymphoedema],Homeless, Carer, [Asylum Seeker],[Suicide and Self Harm])
	) piv_max_code

--------------------------------------------------------------------------------------------
drop table if exists #MAX_VALUE
select *
into #MAX_VALUE
from #MAX_VALUE_INTERNAL --src6
pivot
	(max([Value])
		for GroupName in ([Frailty],
			[Cholesterol],
			[HDL Cholesterol],
			[LDL Cholesterol],
			[BP Diastolic],
			[BP Systolic],
			[BMI],
			[HbA1C],
			[eGFR],
			[FEV1/FVC],
			[Microalbuminuria (Code)],
			[Albuminuria (ACR)],
			[Spirometry],
			[Qrisk Score],
			[Framingham Score],
			[JBS Risk Score],
			[Pulse Rate],
			[Creatinine (All in last 1 year)],
			[Urine Protein Test],
			[CHA2DS2 VASC],
			[SERUM ALBUMIN],
			[TOTAL BILIRUBIN],
			[PROTHROMBIN TIME / INR])
	) piv_max_value

--------------------------------------------------------------------------------------------
/*CREATE THE MIN TABLES, THE COMPLICATED ONES*/
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--ALL DATES FOR EVERY PERSON & GROUP

drop table if exists #MIN_DATE_INTERNAL
select Pseudo_NHS_Number, coalesce(GroupName,'') as GroupName, [Date] as MIN_DATE
into #MIN_DATE_INTERNAL
from Client_SystemP_RW.RP101_PCA
group by Pseudo_NHS_Number, coalesce(GroupName,''), [Date]

--------------------------------------------------------------------------------------------
--1ST MOST RECENT CODE FOUND FOR EVERY PERSON & GROUP

drop table if exists #MIN_CODE_INTERNAL
select distinct B.Pseudo_NHS_Number, B.GroupName, B.Code 
into #MIN_CODE_INTERNAL
from
	(select Pseudo_NHS_Number, coalesce(GroupName, '') as GroupName,  MIN(Date) as Date
	from Client_SystemP_RW.RP101_PCA
	group by Pseudo_NHS_Number, coalesce(GroupName, '') 
	) as A
inner join Client_SystemP_RW.RP101_PCA as B
on A.Pseudo_NHS_Number=B.Pseudo_NHS_Number
	and A.GroupName=B.GroupName
	and A.date=B.Date

--------------------------------------------------------------------------------------------
--1ST MOST RECENT VALUE FOUND FOR EVERY PERSON & GROUP

drop table if exists #MIN_VALUE_INTERNAL
select distinct B.Pseudo_NHS_Number, B.GroupName, B.Value 
into #MIN_VALUE_INTERNAL
from
	(select Pseudo_NHS_Number, coalesce(GroupName, '') as GroupName,  MIN(Date) as Date--row_number() OVER (PARTITION BY Pseudo_NHS_Number, GroupName, Code ORDER BY Pseudo_NHS_Number, Date DESC) as RowNum 
	from Client_SystemP_RW.RP101_PCA
	group by Pseudo_NHS_Number, coalesce(GroupName, '') 
	) as A
inner join Client_SystemP_RW.RP101_PCA as B
on A.Pseudo_NHS_Number=B.Pseudo_NHS_Number
	and A.GroupName=B.GroupName
	and A.Date=B.Date

-------------------------------------------------------------------------------------------
drop table if exists #MIN_DATE
select *
into #MIN_DATE
from #MIN_DATE_INTERNAL --src2
pivot
	(MIN(MIN_DATE)
		for GroupName in (Epilepsy,Diabetes,[Impaired Glucose Regulation],Retinopathy,CKD,Hypertension,COPD,Asthma,CHD,Stroke,TIA,[PVD / PAD],[MI Register],Angina,[Heart Failure],[Atrial Fibrillation],
			[Chronic Liver disease],[Bladder Cancer],[Breast Cancer],[Cervical Cancer],[Bowel Cancer],[Prostate Cancer],[Skin Cancer],[Other Cancers],Schizophrenia,[Bipolar Affective Disorder],
			[Other Psychosis],Dementia,Depression,Anxiety,[Palliative Care Register/End of Life Care Register],[Pulmonary Embolism],[Learning Disabilities],Dysphagia,Autism,
			[Psychoactive Substance Misuse Disorder],[Psychotic Disorder],[Age-related Macular Degeneration],[Primary Open-Angle Glaucoma],Blind,[Partially Sighted],[Hearing Impaired],
			[Neurosis],[Poisoning],[Sprain],[Mental disorder],[Gastro-intestinal disorder],[Frailty],[Cholesterol (non-values)],[HbA1C (non-values) Code],[Microalbuminuria Code],
			[Alcohol Consumption],[Alcohol Status],[Alcohol advice],[Brief Intervention (alcohol)],[JBS Risk Score],[Proteinuria],[Smoking Status],[Pulse Rate],[Pulse Rhythm],[MRC Breathless Scale],[Asthma Severity],
			[Asthma Control Steps],[Heart Failure diagnosed via echocardiogram],[Smoking cessation advice],[Referral to Smoking Cessation Clinic],[DNA Smoking Cessation Clinic],[Exercise Advice],
			[Diet Advice],[Mental Health Care plan],[Referral to Pulmonary rehabilitation],[Pulmonary rehabilitation programme commenced],[Pulmonary rehabilitation programme completed],
			[COPD Self management Plan],[COPD Rescue Pack],[Offered Structured Education (Diabetes)],[Attended Structured Education (Diabetes)],[Completed Structured Education (DIabetes)],
			[Insulin Passport],[Referred to cardiac rehabilitation],[Cardiac rehabilitation declined],[Cardiac rehabilitation],[Cardiac Rehabilitation Completed],[Diabetes review (Annual)],
			[Diabetes review (Other)],[Diabetes Care setting],[Referred to Dietician],[Diabetic foot review],[Diabetic Neuropathy testing],[CHD review],[Medication Review],[Medication Review Declined],
			[COPD Annual Review],[Heart Failure review],[Mental Health Review],[Dementia Review],[Depression review],[Depression screening/questionnaire],[Bowel Screening],
			[Bowel Screening Declined],[NHS Health Checks],[Cervical Screening],[Learning Disabilities Health Assessment],[DNA Bowel cancer screening],[CVD Risk assessment declined],
			[DNA NHS Health Check],[Diabetic Retinal Screening � needs checking],[Cervical cytology exceptions],[Hysterectomy and equivalent ],[Spirometry contraindicated/declined],
			[ACE / A2RA MIN Tolerated Dose],[Cholesterol],[HDL Cholesterol],[LDL Cholesterol],[BP Diastolic],[BP Systolic],[BMI],[HbA1C],[eGFR],[FEV1/FVC],[Microalbuminuria (Code)],[Albuminuria (ACR)],
			[Spirometry],[Qrisk Score],[Framingham Score],[Creatinine (All in last 1 year)],[Urine Protein Test],[CHA2DS2 VASC],[SERUM ALBUMIN],[TOTAL BILIRUBIN],[PROTHROMBIN TIME / INR],
			[Chronic pain],[Parkinsons disease],[Multiple sclerosis],[Motor neurone disease],[Respiratory failure],[Kidney failure],[Osteoporosis],[Osteoarthritis],[Rheumatoid arthritis],
			[Ankylosing spondylitis],[Spondylosis and allied disorders],[Lupus],[Fibromyalgia],[Gout],[Reactive Septic arthritis],[Psoriatic arthritis],[Osteomalacia],[Polymyositis],
			[Polymyalgia rheumatica],[Sicca (Sjogrens) syndrome],[Scleroderma],[Tendonitis],[Familial Hypercholesterolaemia],[Crohns disease],[Coeliac disease],[Ulcerative colitis],
			[Inflammatory bowel disease],[Diverticulitis],[Diverticulosis],[Barretts oesophagus],[Physical Disability]
			,[Attention Deficit Hyperactivity Disorder],[Frailty Index],[Lymphoedema],Homeless, Carer, [Asylum Seeker],[Suicide and Self Harm])
	) piv_MIN 

--------------------------------------------------------------------------------------------

drop table if exists #MIN_CODE
select *
into #MIN_CODE
from #MIN_CODE_INTERNAL --src5
pivot
	(MIN(Code)
		for GroupName in (Epilepsy,Diabetes,[Impaired Glucose Regulation],Retinopathy,CKD,Hypertension,COPD,Asthma,CHD,Stroke,TIA,[PVD / PAD],[MI Register],Angina,[Heart Failure],[Atrial Fibrillation],
              [Chronic Liver disease],[Bladder Cancer],[Breast Cancer],[Cervical Cancer],[Bowel Cancer],[Prostate Cancer],[Skin Cancer],[Other Cancers],Schizophrenia,[Bipolar Affective Disorder],
              [Other Psychosis],Dementia,Depression,Anxiety,[Palliative Care Register/End of Life Care Register],[Pulmonary Embolism],[Learning Disabilities],Dysphagia,Autism,
              [Psychoactive Substance Misuse Disorder],[Psychotic Disorder],[Age-related Macular Degeneration],[Primary Open-Angle Glaucoma],Blind,[Partially Sighted],[Hearing Impaired],
              [Neurosis],[Poisoning],[Sprain],[Mental disorder],[Gastro-intestinal disorder],[Frailty],[Cholesterol (non-values)],[HbA1C (non-values) Code],[Microalbuminuria Code],
              [Alcohol Consumption],[Alcohol Status],[Alcohol advice],[Brief Intervention (alcohol)],[JBS Risk Score],[Proteinuria],[Smoking Status],[Pulse Rate],[Pulse Rhythm],[MRC Breathless Scale],[Asthma Severity],
              [Asthma Control Steps],[Heart Failure diagnosed via echocardiogram],[Smoking cessation advice],[Referral to Smoking Cessation Clinic],[DNA Smoking Cessation Clinic],[Exercise Advice],
              [Diet Advice],[Mental Health Care plan],[Referral to Pulmonary rehabilitation],[Pulmonary rehabilitation programme commenced],[Pulmonary rehabilitation programme completed],
              [COPD Self management Plan],[COPD Rescue Pack],[Offered Structured Education (Diabetes)],[Attended Structured Education (Diabetes)],[Completed Structured Education (DIabetes)],
              [Insulin Passport],[Referred to cardiac rehabilitation],[Cardiac rehabilitation declined],[Cardiac rehabilitation],[Cardiac Rehabilitation Completed],[Diabetes review (Annual)],
              [Diabetes review (Other)],[Diabetes Care setting],[Referred to Dietician],[Diabetic foot review],[Diabetic Neuropathy testing],[CHD review],[Medication Review],[Medication Review Declined],
              [COPD Annual Review],[Heart Failure review],[Mental Health Review],[Dementia Review],[Depression review],[Depression screening/questionnaire],[Bowel Screening],
              [Bowel Screening Declined],[NHS Health Checks],[Cervical Screening],[Learning Disabilities Health Assessment],[DNA Bowel cancer screening],[CVD Risk assessment declined],
              [DNA NHS Health Check],[Diabetic Retinal Screening � needs checking],[Cervical cytology exceptions],[Hysterectomy and equivalent ],[Spirometry contraindicated/declined],
              [ACE / A2RA MIN Tolerated Dose],[Cholesterol],[HDL Cholesterol],[LDL Cholesterol],[BP Diastolic],[BP Systolic],[BMI],[HbA1C],[eGFR],[FEV1/FVC],[Microalbuminuria (Code)],[Albuminuria (ACR)],
              [Spirometry],[Qrisk Score],[Framingham Score],[Creatinine (All in last 1 year)],[Urine Protein Test],[Chronic pain],[Parkinsons disease],[Multiple sclerosis],[Motor neurone disease],
              [Respiratory failure],[Kidney failure],[Osteoporosis],[Osteoarthritis],[Rheumatoid arthritis],[Ankylosing spondylitis],[Spondylosis and allied disorders],[Lupus],[Fibromyalgia],
              [Gout],[Reactive Septic arthritis],[Psoriatic arthritis],[Osteomalacia],[Polymyositis],[Polymyalgia rheumatica],[Sicca (Sjogrens) syndrome],[Scleroderma],[Tendonitis],[Familial Hypercholesterolaemia],
              [Crohns disease],[Coeliac disease],[Ulcerative colitis],[Inflammatory bowel disease],[Diverticulitis],[Diverticulosis],[Barretts oesophagus],[Physical Disability]
			  ,[Attention Deficit Hyperactivity Disorder],[Frailty Index],[Lymphoedema],Homeless, Carer, [Asylum Seeker],[Suicide and Self Harm])
	) piv_MIN_code

--------------------------------------------------------------------------------------------

drop table if exists #MIN_VALUE
select *
into #MIN_VALUE
from #MIN_VALUE_INTERNAL --src6
pivot
	(MIN([Value])
		for GroupName in ([Frailty],
			[Cholesterol],
			[HDL Cholesterol],
			[LDL Cholesterol],
			[BP Diastolic],
			[BP Systolic],
			[BMI],
			[HbA1C],
			[eGFR],
			[FEV1/FVC],
			[Microalbuminuria (Code)],
			[Albuminuria (ACR)],
			[Spirometry],
			[Qrisk Score],
			[Framingham Score],
			[JBS Risk Score],
			[Pulse Rate],
			[Creatinine (All in last 1 year)],
			[Urine Protein Test],
			[CHA2DS2 VASC],
			[SERUM ALBUMIN],
			[TOTAL BILIRUBIN],
			[PROTHROMBIN TIME / INR])
	) piv_MIN_value


/* now there are tables with min and max dates and values and can be added to the conditions */


drop table if exists Client_SystemP_RW.RP102_Conditions
select  MPI.Pseudo_NHS_Number
		,GPPracticeCode
		,X_CCG_OF_REGISTRATION
        ,X_CCG_OF_RESIDENCE
        ,Dob
        ,Age
        ,Sex
        ,EthnicGroup
        ,EthnicSubGroup
        ,InterpreterRequired
        ,Deceased
		,LSOA
		,LSOADecile
		,WardCode
		,WardName
		,LAT
		,LONG
		,FrailtyScore 
		--,case when Age>=65 and ([MAXC].[Frailty] = '925791000000100' or ([MAXC].[Frailty] = '248279007' and FrailtyScore>=0.12 and FrailtyScore<0.25)) then 'Mild'
		--	when Age>=65 and ([MAXC].[Frailty] = '925831000000107' or ([MAXC].[Frailty] = '248279007' and FrailtyScore>=0.25 and FrailtyScore<0.36)) then 'Moderate'
		--	when Age>=65 and ([MAXC].[Frailty] = '925861000000102' or ([MAXC].[Frailty] = '248279007' and FrailtyScore>=0.36)) then 'Severe' end as FrailtyLevel
		,case when Age>=65 and (FrailtyScore>=0.12 and FrailtyScore<0.25) then 'Mild'
			when Age>=65 and (FrailtyScore>=0.25 and FrailtyScore<0.36) then 'Moderate'
			when Age>=65 and (FrailtyScore>=0.36) then 'Severe' end as FrailtyLevel
		,TotalHousehold
		,LivingAlone
		,LivingWithUnder18
		,UPRNMatch,
		[MAX].Epilepsy as EPILEPSY_MAX,
		[MAXC].Epilepsy as EPILEPSY_MAX_CODE,
		[MAX].Diabetes as DIABETES_MAX,
		[MAXC].Diabetes as DIABETES_MAX_CODE,
		[MAX].[Impaired Glucose Regulation] as IGR_MAX,
		[MAXC].[Impaired Glucose Regulation] as IGR_MAX_CODE,
		[MAX].Retinopathy as RETINOPATHY_MAX,
		[MAXC].Retinopathy as RETINOPATHY_MAX_CODE,
		[MAX].CKD as CKD_MAX,
		[MAXC].CKD as CKD_MAX_CODE,
		[MAX].Hypertension as HYPERTENSION_MAX,
		[MAXC].Hypertension as HYPERTENSION_MAX_CODE,
		[MAX].COPD as COPD_MAX,
		[MAXC].COPD as COPD_MAX_CODE,
		[MAX].Asthma as ASTHMA_MAX,
		[MAXC].Asthma as ASTHMA_MAX_CODE,
		[MAX].CHD as CHD_MAX,
		[MAXC].CHD as CHD_MAX_CODE,
		[MAX].Stroke as STROKE_MAX,
		[MAXC].Stroke as STROKE_MAX_CODE,
		[MAX].TIA as TIA_MAX,
		[MAXC].TIA as TIA_MAX_CODE,
		[MAX].[PVD / PAD] as PVD_PAD_MAX,
		[MAXC].[PVD / PAD] as PVD_PAD_MAX_CODE,
		[MAX].[MI Register] as MI_MAX,
		[MAXC].[MI Register] as MI_MAX_CODE,
		[MAX].Angina as ANGINA_MAX,
		[MAXC].Angina as ANGINA_MAX_CODE,
		[MAX].[Heart Failure] as HF_MAX,
		[MAXC].[Heart Failure] as HF_MAX_CODE,
		[MAX].[Atrial Fibrillation] as AF_MAX,
		[MAXC].[Atrial Fibrillation] as AF_MAX_CODE,
		[MAX].[Chronic Liver disease] as CLD_MAX,
		[MAXC].[Chronic Liver disease] as CLD_MAX_CODE,
		[MAX].[Bladder Cancer] as BLADDER_CANCER_MAX,
		[MAXC].[Bladder Cancer] as BLADDER_CANCER_MAX_CODE,
		[MAX].[Breast Cancer] as BREAST_CANCER_MAX,
		[MAXC].[Breast Cancer] as BREAST_CANCER_MAX_CODE,
		[MAX].[Cervical Cancer] as CERVICAL_CANCER_MAX,
		[MAXC].[Cervical Cancer] as CERVICAL_CANCER_MAX_CODE,
		[MAX].[Bowel Cancer] as BOWEL_CANCER_MAX,
		[MAXC].[Bowel Cancer] as BOWEL_CANCER_MAX_CODE,
		[MAX].[Prostate Cancer] as PROSTATE_CANCER_MAX,
		[MAXC].[Prostate Cancer] as PROSTATE_CANCER_MAX_CODE,
		[MAX].[Skin Cancer] as SKIN_CANCER_MAX,
		[MAXC].[Skin Cancer] as SKIN_CANCER_MAX_CODE,
		[MAX].[Other Cancers] as OTHER_CANCERS_MAX,
		[MAXC].[Other Cancers] as OTHER_CANCERS_MAX_CODE,
		[MAX].Schizophrenia as SCHIZOPHRENIA_MAX,
		[MAXC].Schizophrenia as SCHIZOPHRENIA_MAX_CODE,
		[MAX].[Bipolar Affective Disorder] as BIPOLAR_MAX,
		[MAXC].[Bipolar Affective Disorder] as BIPOLAR_MAX_CODE,
		[MAX].[Other Psychosis] as OTHER_PSYCHOSIS_MAX,
		[MAXC].[Other Psychosis] as OTHER_PSYCHOSIS_MAX_CODE,
		[MAX].Dementia as DEMENTIA_MAX,
		[MAXC].Dementia as DEMENTIA_MAX_CODE,
		[MAX].Depression as DERPRESSION_MAX,
		[MAXC].Depression as DERPRESSION_MAX_CODE,
		[MAX].Anxiety as ANXIETY_MAX,
		[MAXC].Anxiety  as ANXIETY_MAX_CODE,
		[MAX].[Palliative Care Register/End of Life Care Register] as PALLIATIVE_EOL_MAX,
		[MAXC].[Palliative Care Register/End of Life Care Register] as PALLIATIVE_EOL_MAX_CODE,
		[MAX].[Pulmonary Embolism] as PULMONARY_EMBOLISM_MAX,
		[MAXC].[Pulmonary Embolism] as PULMONARY_EMBOLISM_MAX_CODE,
		[MAX].[Learning Disabilities] as LEARNING_DISABILITIES_MAX,
		[MAXC].[Learning Disabilities] as LEARNING_DISABILITIES_MAX_CODE,
		[MAX].Dysphagia as DYSPHAGIA_MAX,
		[MAXC].Dysphagia as DYSPHAGIA_MAX_CODE,
		[MAX].Autism as AUTISM_MAX,
		[MAXC].Autism as AUTISM_MAX_CODE,
		[MAX].[Psychoactive Substance Misuse Disorder] as PSYCHOACTIVE_SUBSTANCE_MISUSE_MAX,
		[MAXC].[Psychoactive Substance Misuse Disorder] as PSYCHOACTIVE_SUBSTANCE_MISUSE_MAX_CODE,
		[MAX].[Psychotic Disorder] as PSYCHOTIC_DISORDER_MAX,
		[MAXC].[Psychotic Disorder] as PSYCHOTIC_DISORDER_MAX_CODE,
		[MAX].[Age-related Macular Degeneration] as AGE_RELATED_MACULAR_DEGEN_MAX,
		[MAXC].[Age-related Macular Degeneration] as AGE_RELATED_MACULAR_DEGEN_MAX_CODE,
		[MAX].[Primary Open-Angle Glaucoma] as PRIMARY_OA_GLAUCOMA_MAX,
		[MAXC].[Primary Open-Angle Glaucoma] as PRIMARY_OA_GLAUCOMA_MAX_CODE,
		[MAX].[Blind] as BLIND_MAX,
		[MAXC].[Blind] as BLIND_MAX_CODE,
		[MAX].[Partially Sighted] as PARTIALLY_SIGHTED_MAX,
		[MAXC].[Partially Sighted] as PARTIALLY_SIGHTED_MAX_CODE,
		[MAX].[Hearing Impaired] as HEARING_IMPAIRED_MAX,
		[MAXC].[Hearing Impaired] as HEARING_IMPAIRED_MAX_CODE,
		[MAX].[Neurosis] as NEUROSIS_MAX,
		[MAXC].[Neurosis] as NEUROSIS_MAX_CODE,
		[MAX].[Poisoning] as POISONING_MAX,
		[MAXC].[Poisoning] as POISONING_MAX_CODE,
		[MAX].[Sprain] as SPRAIN_MAX,
		[MAXC].[Sprain] as SPRAIN_MAX_CODE,
		[MAX].[Mental disorder] as MENTAL_DISORDER_MAX,
		[MAXC].[Mental disorder] as MENTAL_DISORDER_MAX_CODE,
		[MAX].[Gastro-intestinal disorder] as GASTROINTESTINAL_DISORDER_MAX,
		[MAXC].[Gastro-intestinal disorder] as GASTROINTESTINAL_DISORDER_MAX_CODE,
		[MAX].[Frailty] as FRAILTY_MAX,
		[MAX].[Frailty] as FRAILTY_MAX_VALUE_DATE,
		[MAXV].[Frailty] as FRAILTY_MAX_VALUE,
		[MAXC].[Frailty] as FRAILTY_MAX_CODE,
		[MAX].[Chronic pain] as CHRONIC_PAIN_MAX,
		[MAXC].[Chronic pain] as CHRONIC_PAIN_MAX_CODE,
		[MAX].[Parkinsons disease] as PARKINSONS_DISEASE_MAX,
		[MAXC].[Parkinsons disease] as PARKINSONS_DISEASE_MAX_CODE,
		[MAX].[Multiple sclerosis] as MULTIPLE_SCLEROSIS_MAX,
		[MAXC].[Multiple sclerosis] as MULTIPLE_SCLEROSIS_MAX_CODE,
		[MAX].[Motor neurone disease] as MOTOR_NEURONE_DISEASE_MAX,
		[MAXC].[Motor neurone disease] as MOTOR_NEURONE_DISEASE_MAX_CODE,
		[MAX].[Respiratory failure] as RESPIRATORY_FAILURE_MAX,
		[MAXC].[Respiratory failure] as RESPIRATORY_FAILURE_MAX_CODE,
		[MAX].[Kidney failure] as KIDNEY_FAILURE_MAX,
		[MAXC].[Kidney failure] as KIDNEY_FAILURE_MAX_CODE,
		[MAX].[Osteoporosis] as OSTEOPOROSIS_MAX,
		[MAXC].[Osteoporosis] as OSTEOPOROSIS_MAX_CODE,
		[MAX].[Osteoarthritis] as OSTEOARTHRITIS_MAX,
		[MAXC].[Osteoarthritis] as OSTEOARTHRITIS_MAX_CODE,
		[MAX].[Rheumatoid arthritis] as RHEUMATOID_ARTHRITIS_MAX,
		[MAXC].[Rheumatoid arthritis] as RHEUMATOID_ARTHRITIS_MAX_CODE,
		[MAX].[Ankylosing spondylitis] as ANKYLOSING_SPONDYLITIS_MAX,
		[MAXC].[Ankylosing spondylitis] as ANKYLOSING_SPONDYLITIS_MAX_CODE,
		[MAX].[Spondylosis and allied disorders] as SPONDYLOSIS_AND_ALLIED_DISORDERS_MAX,
		[MAXC].[Spondylosis and allied disorders] as SPONDYLOSIS_AND_ALLIED_DISORDERS_MAX_CODE,
		[MAX].[Lupus] as LUPUS_MAX,
		[MAXC].[Lupus] as LUPUS_MAX_CODE,
		[MAX].[Fibromyalgia] as FIBROMYALGIA_MAX,
		[MAXC].[Fibromyalgia] as FIBROMYALGIA_MAX_CODE,
		[MAX].[Gout] as GOUT_MAX,
		[MAXC].[Gout] as GOUT_MAX_CODE,
		[MAX].[Reactive Septic arthritis] as REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MAX,
		[MAXC].[Reactive Septic arthritis] as REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MAX_CODE,
		[MAX].[Psoriatic arthritis] as PSORIATIC_ARTHRITIS_MAX,
		[MAXC].[Psoriatic arthritis] as PSORIATIC_ARTHRITIS_MAX_CODE,
		[MAX].[Osteomalacia] as OSTEOMALACIA_MAX,
		[MAXC].[Osteomalacia] as OSTEOMALACIA_MAX_CODE,
		[MAX].[Polymyositis] as POLYMYOSITIS_MAX,
		[MAXC].[Polymyositis] as POLYMYOSITIS_MAX_CODE,
		[MAX].[Polymyalgia rheumatica] as POLYMYALGIA_RHEUMATICA_MAX,
		[MAXC].[Polymyalgia rheumatica] as POLYMYALGIA_RHEUMATICA_MAX_CODE,
		[MAX].[Sicca (Sjogrens) syndrome] as SJOGRENS_SYNDROME_MAX,
		[MAXC].[Sicca (Sjogrens) syndrome] as SJOGRENS_SYNDROME_MAX_CODE,
		[MAX].[Scleroderma] as SCLERODERMA_MAX,
		[MAXC].[Scleroderma] as SCLERODERMA_MAX_CODE,
		[MAX].[Tendonitis] as TENDONITIS_MAX,
		[MAXC].[Tendonitis] as TENDONITIS_MAX_CODE,
		[MAX].[Familial Hypercholesterolaemia] as FAMILIAL_HYPERCHOLESTEROLAEMIA_MAX,
		[MAXC].[Familial Hypercholesterolaemia] as FAMILIAL_HYPERCHOLESTEROLAEMIA_MAX_CODE,
		[MAX].[Crohns disease] as CROHNS_DISEASE_MAX,
		[MAXC].[Crohns disease] as CROHNS_DISEASE_MAX_CODE,
		[MAX].[Coeliac disease] as COELIAC_DISEASE_MAX,
		[MAXC].[Coeliac disease] as COELIAC_DISEASE_MAX_CODE,
		[MAX].[Ulcerative colitis] as ULCERATIVE_COLITIS_MAX,
		[MAXC].[Ulcerative colitis] as ULCERATIVE_COLITIS_MAX_CODE,
		[MAX].[Inflammatory bowel disease] as INFLAMMATORY_BOWEL_DISEASE_MAX,
		[MAXC].[Inflammatory bowel disease] as INFLAMMATORY_BOWEL_DISEASE_MAX_CODE,
		[MAX].[Diverticulitis] as DIVERTICULITIS_MAX,
		[MAXC].[Diverticulitis] as DIVERTICULITIS_MAX_CODE,
		[MAX].[Diverticulosis] as DIVERTICULOSIS_MAX,
		[MAXC].[Diverticulosis] as DIVERTICULOSIS_MAX_CODE,
		[MAX].[Barretts oesophagus] as BARRETTS_OESOPHAGUS_MAX,
		[MAXC].[Barretts oesophagus] as BARRETTS_OESOPHAGUS_MAX_CODE,
		[MAX].[Physical Disability] as PHYSICAL_DISABILITY_MAX,
		[MAXC].[Physical Disability] as PHYSICAL_DISABILITY_MAX_CODE,
		[MAX].[Cholesterol] as CHOLESTEROL_MAX,
		[MAXV].[Cholesterol] as CHOLESTEROL_MAX_VALUE,
		[MAX].[Cholesterol (non-values)] as CHOLESTEROL_NONVALUES_MAX,
		[MAXC].[Cholesterol (non-values)] as CHOLESTEROL_NONVALUES_MAX_CODE,
		[MAX].[HDL Cholesterol] as HDL_CHOLESTEROL_MAX,
		[MAXV].[HDL Cholesterol] as HDL_CHOLESTEROL_MAX_VALUE,
		[MAX].[LDL Cholesterol] as LDL_CHOLESTEROL_MAX,
		[MAXV].[LDL Cholesterol] as LDL_CHOLESTEROL_MAX_VALUE,
		[MAX].[BP Diastolic] as BP_DIASTOLIC_MAX,
		[MAXV].[BP Diastolic] as BP_DIASTOLIC_MAX_VALUE,
		[MAX].[BP Systolic] as BP_SYSTOLIC_MAX,
		[MAXV].[BP Systolic] as BP_SYSTOLIC_MAX_VALUE,
		[MAX].[BMI] as BMI_MAX,
		[MAXV].[BMI] as BMI_MAX_VALUE,
		[MAX].[HbA1C] as HbA1C_MAX,
		[MAXV].[HbA1C] as HbA1C_MAX_VALUE,
		[MAX].[HbA1C (non-values) Code] as HBA1C_NONVALUES_CODE_MAX,
		[MAXC].[HbA1C (non-values) Code] as HBA1C_NONVALUES_CODE_MAX_CODE,
		[MAX].[eGFR] as eGFR_MAX,
		[MAXV].[eGFR] as eGFR_MAX_VALUE,
		[MAX].[FEV1/FVC] as FEV1_FVC_MAX,
		[MAXV].[FEV1/FVC] as FEV1_FVC_MAX_VALUE,
		[MAX].[Microalbuminuria (Code)] as MICROALBUMINURIA_MAX,
		[MAXV].[Microalbuminuria (Code)] as MICROALBUMINURIA_MAX_VALUE,
		[MAX].[Microalbuminuria Code] as MICROALBUMINURIA_CODE_MAX,
		[MAXC].[Microalbuminuria Code] as MICROALBUMINURIA_CODE_MAX_CODE,
		[MAX].[Albuminuria (ACR)] as ACR_MAX,
		[MAXV].[Albuminuria (ACR)] as ACR_MAX_VALUE,
		[MAX].[Alcohol Consumption] as ALCOHOL_CONSUMPTION_MAX,
		[MAXC].[Alcohol Consumption] as ALCOHOL_CONSUMPTION_MAX_CODE,
		[MAX].[Alcohol Status] as ALCOHOL_STATUS_MAX,
		[MAXC].[Alcohol Status] as ALCOHOL_STATUS_MAX_CODE,
		[MAX].[Alcohol advice] as ALCOHOL_ADVICE_MAX,
		[MAXC].[Alcohol advice] as ALCOHOL_ADVICE_MAX_CODE,
		[MAX].[Brief Intervention (alcohol)] as BRIEF_INTERVENTION_ALCOHOL_MAX,
		[MAXC].[Brief Intervention (alcohol)] as BRIEF_INTERV_ALCOHOL_MAX_CODE,
		[MAX].[Spirometry] as SPIROMETRY_MAX,
		[MAXV].[Spirometry] as SPIROMETRY_MAX_VALUE,
		[MAX].[Qrisk Score] as QRISK_SCORE_MAX,
		[MAXV].[Qrisk Score] as QRISK_SCORE_MAX_VALUE,
		[MAX].[Framingham Score] as FRAMINGHAM_SCORE_MAX,
		[MAXV].[Framingham Score] as FRAMINGHAM_SCORE_MAX_VALUE,
		[MAX].[JBS Risk Score] as JBS_RISK_SCORE_MAX,
		[MAXC].[JBS Risk Score] as JBS_RISK_SCORE_MAX_CODE,
		
		[MAX].[Pulse Rate] as PULSE_RATE_MAX,
		[MAXV].[Pulse Rate] as PULSE_RATE_MAX_VALUE,
		[MAXC].[Pulse Rate] as PULSE_RATE_MAX_CODE,

		[MAX].[Creatinine (All in last 1 year)] as CREATININE_MAX,
		[MAXV].[Creatinine (All in last 1 year)] as CREATININE_MAX_VALUE,
		[MAX].[Urine Protein Test] as URINE_PROTEIN_TEST_MAX,
		[MAXV].[Urine Protein Test] as URINE_PROTEIN_TEST_VALUE_MAX,
		[MAX].[Proteinuria] as PROTEINURIA_MAX,
		[MAXC].[Proteinuria] as PROTEINURIA_MAX_CODE,
		[MAX].[CHA2DS2 VASC] as CHA2DS2_VASC_MAX,
		[MAXV].[CHA2DS2 VASC] as CHA2DS2_VASC_VALUE_MAX,
		[MAX].[SERUM ALBUMIN] as SERUM_ALBUMIN_MAX,
		[MAXV].[SERUM ALBUMIN] as SERUM_ALBUMIN_VALUE_MAX,
		[MAX].[TOTAL BILIRUBIN] as TOTAL_BILIRUBIN_MAX,
		[MAXV].[TOTAL BILIRUBIN] as TOTAL_BILIRUBIN_VALUE_MAX,
		[MAX].[PROTHROMBIN TIME / INR] as PROTHROMBIN_TIME_INR_MAX,
		[MAXV].[PROTHROMBIN TIME / INR] as PROTHROMBIN_TIME_INR_VALUE_MAX,
		[MAX].[Smoking Status] as SMOKING_STATUS_MAX,
		[MAXC].[Smoking Status] as SMOKING_STATUS_MAX_CODE,
		[MAX].[Pulse Rhythm] as PULSE_RHYTHM_MAX,
		[MAXC].[Pulse Rhythm] as PULSE_RHYTHM_MAX_CODE,
		[MAX].[MRC Breathless Scale] as MRC_BREATHLESS_SCALE_MAX,
		[MAXC].[MRC Breathless Scale] as MRC_BREATHLESS_SCALE_MAX_CODE,
		[MAX].[Asthma Severity] as ASTHMA_SEVERITY_MAX,
		[MAXC].[Asthma Severity] as ASTHMA_SEVERITY_MAX_CODE,
		[MAX].[Asthma Control Steps] as ASTHMA_CONTROL_STEPS_MAX,
		[MAXC].[Asthma Control Steps] as ASTHMA_CONTROL_STEPS_MAX_CODE,
		[MAX].[Heart Failure diagnosed via echocardiogram] as HEART_FAILURE_DIAG_ECHOCARDIOGRAM_MAX,
		[MAXC].[Heart Failure diagnosed via echocardiogram] as HEART_FAILURE_DIAG_ECHOCARDIOGRAM_MAX_CODE,
		[MAX].[Smoking cessation advice] as SMOKING_CESSATION_ADVICE_MAX,
		[MAXC].[Smoking cessation advice] as SMOKING_CESSATION_ADVICE_MAX_CODE,
		[MAX].[Referral to Smoking Cessation Clinic] as REFERRAL_TO_SMOKING_CESSATION_CLINIC_MAX,
		[MAXC].[Referral to Smoking Cessation Clinic] as REFERRAL_TO_SMOKING_CESSATION_CLINIC_MAX_CODE,
		[MAX].[DNA Smoking Cessation Clinic] as DNA_SMOKING_CESSATION_CLINIC_MAX,
		[MAXC].[DNA Smoking Cessation Clinic] as DNA_SMOKING_CESSATION_CLINIC_MAX_CODE,
		[MAX].[Exercise Advice] as EXERCISE_ADVICE_MAX,
		[MAXC].[Exercise Advice] as EXERCISE_ADVICE_MAX_CODE,
		[MAX].[Diet Advice] as DIET_ADVICE_MAX,
		[MAXC].[Diet Advice] as DIET_ADVICE_MAX_CODE,
		[MAX].[Mental Health Care plan] as MENTAL_HEALTH_CARE_PLAN_MAX,
		[MAXC].[Mental Health Care plan] as MENTAL_HEALTH_CARE_PLAN_MAX_CODE,
		[MAX].[Referral to Pulmonary rehabilitation] as REFERRAL_TO_PULMONARY_REHAB_MAX,
		[MAXC].[Referral to Pulmonary rehabilitation] as REFERRAL_TO_PULMONARY_REHAB_MAX_CODE,
		[MAX].[Pulmonary rehabilitation programme commenced] as PULMONARY_REHAB_PROGRAMME_COMMENCED_MAX,
		[MAXC].[Pulmonary rehabilitation programme commenced] as PULMONARY_REHAB_PROGRAMME_COMMENCED_MAX_CODE,
		[MAX].[Pulmonary rehabilitation programme completed] as PULMONARY_REHAB_PROGRAMME_COMPLETED_MAX,
		[MAXC].[Pulmonary rehabilitation programme completed] as PULMONARY_REHAB_PROGRAMME_COMPLETED_MAX_CODE,
		[MAX].[COPD Self management Plan] as COPD_SELF_MANAGEMENT_PLAN_MAX,
		[MAXC].[COPD Self management Plan] as COPD_SELF_MANAGEMENT_PLAN_MAX_CODE,
		[MAX].[COPD Rescue Pack] as COPD_RESCUE_PACK_MAX,
		[MAXC].[COPD Rescue Pack] as COPD_RESCUE_PACK_MAX_CODE,
		[MAX].[Offered Structured Education (Diabetes)] as OFFERED_STRUCTURED_EDUCAT_DIABETES_MAX,
		[MAXC].[Offered Structured Education (Diabetes)] as OFFERED_STRUCTURED_EDUCAT_DIABETES_MAX_CODE,
		[MAX].[Attended Structured Education (Diabetes)] as ATTENDED_STRUCTURED_EDUCAT_DIABETES_MAX,
		[MAXC].[Attended Structured Education (Diabetes)] as ATTENDED_STRUCTURED_EDUCAT_DIABETES_MAX_CODE,
		[MAX].[Completed Structured Education (DIabetes)] as COMPLETED_STRUCTURED_EDUCAT_DIABETES_MAX,
		[MAXC].[Completed Structured Education (DIabetes)] as COMPLETED_STRUCTURED_EDUCAT_DIABETES_MAX_CODE,
		[MAX].[Insulin Passport] as INSULIN_PASSPORT_MAX,
		[MAXC].[Insulin Passport] as INSULIN_PASSPORT_MAX_CODE,
		[MAX].[Referred to cardiac rehabilitation] as REFERRED_TO_CARDIAC_REHABILITATION_MAX,
		[MAXC].[Referred to cardiac rehabilitation] as REFERRED_TO_CARDIAC_REHABILITATION_MAX_CODE,
		[MAX].[Cardiac rehabilitation declined] as CARDIAC_REHABILITATION_DECLINED_MAX,
		[MAXC].[Cardiac rehabilitation declined] as CARDIAC_REHABILITATION_DECLINED_MAX_CODE,
		[MAX].[Cardiac rehabilitation] as CARDIAC_REHABILITATION_MAX,
		[MAXC].[Cardiac rehabilitation] as CARDIAC_REHABILITATION_MAX_CODE,
		[MAX].[Cardiac Rehabilitation Completed] as CARDIAC_REHABILITATION_COMPLETED_MAX,
		[MAXC].[Cardiac Rehabilitation Completed] as CARDIAC_REHABILITATION_COMPLETED_MAX_CODE,
		[MAX].[Diabetes review (Annual)] as DIABETES_REVIEW_ANNUAL_MAX,
		[MAXC].[Diabetes review (Annual)] as DIABETES_REVIEW_ANNUAL_MAX_CODE,
		[MAX].[Diabetes review (Other)] as DIABETES_REVIEW_OTHER_MAX,
		[MAXC].[Diabetes review (Other)] as DIABETES_REVIEW_OTHER_MAX_CODE,
		[MAX].[Diabetes Care setting] as DIABETES_CARE_SETTING_MAX,
		[MAXC].[Diabetes Care setting] as DIABETES_CARE_SETTING_MAX_CODE,
		[MAX].[Referred to Dietician] as REFERRED_TO_DIETICIAN_MAX,
		[MAXC].[Referred to Dietician] as REFERRED_TO_DIETICIAN_MAX_CODE,
		[MAX].[Diabetic foot review] as DIABETIC_FOOT_REVIEW_MAX,
		[MAXC].[Diabetic foot review] as DIABETIC_FOOT_REVIEW_MAX_CODE,
		[MAX].[Diabetic Neuropathy testing] as DIABETIC_NEUROPATHY_TESTING_MAX,
		[MAXC].[Diabetic Neuropathy testing] as DIABETIC_NEUROPATHY_TESTING_MAX_CODE,
		[MAX].[CHD review] as CHD_REVIEW_MAX,
		[MAXC].[CHD review] as CHD_REVIEW_MAX_CODE,
		[MAX].[Medication Review] as MEDICATION_REVIEW_MAX,
		[MAXC].[Medication Review] as MEDICATION_REVIEW_MAX_CODE,
		[MAX].[Medication Review Declined] as MEDICATION_REVIEW_DECLINED_MAX,
		[MAXC].[Medication Review Declined] as MEDICATION_REVIEW_DECLINED_MAX_CODE,
		[MAX].[COPD Annual Review] as COPD_ANNUAL_REVIEW_MAX,
		[MAXC].[COPD Annual Review] as COPD_ANNUAL_REVIEW_MAX_CODE,
		[MAX].[Heart Failure review] as HEART_FAILURE_REVIEW_MAX,
		[MAXC].[Heart Failure review] as HEART_FAILURE_REVIEW_MAX_CODE,
		[MAX].[Mental Health Review] as MENTAL_HEALTH_REVIEW_MAX,
		[MAXC].[Mental Health Review] as MENTAL_HEALTH_REVIEW_MAX_CODE,
		[MAX].[Dementia Review] as DEMENTIA_REVIEW_MAX,
		[MAXC].[Dementia Review] as DEMENTIA_REVIEW_MAX_CODE,
		[MAX].[Depression review] as DEPRESSION_REVIEW_MAX,
		[MAXC].[Depression review] as DEPRESSION_REVIEW_MAX_CODE,
		[MAX].[Depression screening/questionnaire] as DEPRESSION_SCREENING_MAX,
		[MAXC].[Depression screening/questionnaire] as DEPRESSION_SCREENING_MAX_CODE,
		[MAX].[Bowel Screening] as BOWEL_SCREENING_MAX,
		[MAXC].[Bowel Screening] as BOWEL_SCREENING_MAX_CODE,
		[MAX].[Bowel Screening Declined] as BOWEL_SCREENING_DECLINED_MAX,
		[MAXC].[Bowel Screening Declined] as BOWEL_SCREENING_DECLINED_MAX_CODE,
		[MAX].[NHS Health Checks] as NHS_HEALTH_CHECKS_MAX,
		[MAXC].[NHS Health Checks] as NHS_HEALTH_CHECKS_MAX_CODE,
		[MAX].[Cervical Screening] as CERVICAL_SCREENING_MAX,
		[MAXC].[Cervical Screening] as CERVICAL_SCREENING_MAX_CODE,
		[MAX].[Learning Disabilities Health Assessment] as LEARNING_DISABILITIES_HEALTH_ASSESSMENT_MAX,
		[MAXC].[Learning Disabilities Health Assessment] as LEARNING_DISABILITIES_HEALTH_ASSESSMENT_MAX_CODE,
		[MAX].[DNA Bowel cancer screening] as DNA_BOWEL_CANCER_SCREENING_MAX,
		[MAXC].[DNA Bowel cancer screening] as DNA_BOWEL_CANCER_SCREENING_MAX_CODE,
		[MAX].[CVD Risk assessment declined] as CVD_RISK_ASSESSMENT_DECLINED_MAX,
		[MAXC].[CVD Risk assessment declined] as CVD_RISK_ASSESSMENT_DECLINED_MAX_CODE,
		[MAX].[DNA NHS Health Check] as DNA_NHS_HEALTH_CHECK_MAX,
		[MAXC].[DNA NHS Health Check] as DNA_NHS_HEALTH_CHECK_MAX_CODE,
		[MAX].[Diabetic Retinal Screening � needs checking] as DIABETIC_RETINAL_SCREENING_MAX,
		[MAXC].[Diabetic Retinal Screening � needs checking] as DIABETIC_RETINAL_SCREENING_MAX_CODE,
		[MAX].[Cervical cytology exceptions] as CERVICAL_CYTOLOGY_EXCEPTIONS_MAX,
		[MAXC].[Cervical cytology exceptions] as CERVICAL_CYTOLOGY_EXCEPTIONS_MAX_CODE,
		[MAX].[Hysterectomy and equivalent ] as HYSTERECTOMY_AND_EQUIVALENT_MAX,
		[MAXC].[Hysterectomy and equivalent ] as HYSTERECTOMY_AND_EQUIVALENT_MAX_CODE,
		[MAX].[Spirometry contraindicated/declined] as SPIROMETRY_CONTRAINDICATED_DECLINED_MAX,
		[MAXC].[Spirometry contraindicated/declined] as SPIROMETRY_CONTRAINDICATED_DECLINED_MAX_CODE,
		[MAX].[ACE / A2RA MAX Tolerated Dose] as ACE_A2RA_MAX_TOLERATED_DOSE_MAX,
		[MAXC].[ACE / A2RA MAX Tolerated Dose] as ACE_A2RA_MAX_TOLERATED_DOSE_MAX_CODE
		,[MAX].[Attention Deficit Hyperactivity Disorder] as [Attention_Deficit_Hyperactivity_Disorder_MAX]
		,[MAXC].[Attention Deficit Hyperactivity Disorder] AS [Attention_Deficit_Hyperactivity_Disorder_MAX_CODE]
		,[MAX].[Frailty Index] as [Frailty_Index_MAX]
		,[MAXC].[Frailty Index] as [Frailty_Index_MAX_CODE]
		,[MAX].[Lymphoedema] as [Lymphoedema_MAX]
		,[MAXC].[Lymphoedema] as [Lymphoedema_MAX_CODE]
		,[MAX].[Homeless] as [Homeless_MAX]
		,[MAXC].[Homeless] as [Homeless_MAX_CODE]
		,[MAX].Carer as [Carer_MAX]
		,[MAXC].Carer as [Carer_MAX_CODE]
		,[MAX].[Asylum Seeker] as [Asylum_Seeker_MAX]
		,[MAXC].[Asylum Seeker] as [Asylum_Seeker_MAX_CODE]
		,[MAX].[Suicide and Self Harm] as SelfHarm_MAX
		,[MAXC].[Suicide and Self Harm] as SelfHarm_MAX_CODE
		,[MIN].Epilepsy as EPILEPSY_MIN,
		[MINC].Epilepsy as EPILEPSY_MIN_CODE,
		[MIN].Diabetes as DIABETES_MIN,
		[MINC].Diabetes as DIABETES_MIN_CODE,
		[MIN].[Impaired Glucose Regulation] as IGR_MIN,
		[MINC].[Impaired Glucose Regulation] as IGR_MIN_CODE,
		[MIN].Retinopathy as RETINOPATHY_MIN,
		[MINC].Retinopathy as RETINOPATHY_MIN_CODE,
		[MIN].CKD as CKD_MIN,
		[MINC].CKD as CKD_MIN_CODE,
		[MIN].Hypertension as HYPERTENSION_MIN,
		[MINC].Hypertension as HYPERTENSION_MIN_CODE,
		[MIN].COPD as COPD_MIN,
		[MINC].COPD as COPD_MIN_CODE,
		[MIN].Asthma as ASTHMA_MIN,
		[MINC].Asthma as ASTHMA_MIN_CODE,
		[MIN].CHD as CHD_MIN,
		[MINC].CHD as CHD_MIN_CODE,
		[MIN].Stroke as STROKE_MIN,
		[MINC].Stroke as STROKE_MIN_CODE,
		[MIN].TIA as TIA_MIN,
		[MINC].TIA as TIA_MIN_CODE,
		[MIN].[PVD / PAD] as PVD_PAD_MIN,
		[MINC].[PVD / PAD] as PVD_PAD_MIN_CODE,
		[MIN].[MI Register] as MI_MIN,
		[MINC].[MI Register] as MI_MIN_CODE,
		[MIN].Angina as ANGINA_MIN,
		[MINC].Angina as ANGINA_MIN_CODE,
		[MIN].[Heart Failure] as HF_MIN,
		[MINC].[Heart Failure] as HF_MIN_CODE,
		[MIN].[Atrial Fibrillation] as AF_MIN,
		[MINC].[Atrial Fibrillation] as AF_MIN_CODE,
		[MIN].[Chronic Liver disease] as CLD_MIN,
		[MINC].[Chronic Liver disease] as CLD_MIN_CODE,
		[MIN].[Bladder Cancer] as BLADDER_CANCER_MIN,
		[MINC].[Bladder Cancer] as BLADDER_CANCER_MIN_CODE,
		[MIN].[Breast Cancer] as BREAST_CANCER_MIN,
		[MINC].[Breast Cancer] as BREAST_CANCER_MIN_CODE,
		[MIN].[Cervical Cancer] as CERVICAL_CANCER_MIN,
		[MINC].[Cervical Cancer] as CERVICAL_CANCER_MIN_CODE,
		[MIN].[Bowel Cancer] as BOWEL_CANCER_MIN,
		[MINC].[Bowel Cancer] as BOWEL_CANCER_MIN_CODE,
		[MIN].[Prostate Cancer] as PROSTATE_CANCER_MIN,
		[MINC].[Prostate Cancer] as PROSTATE_CANCER_MIN_CODE,
		[MIN].[Skin Cancer] as SKIN_CANCER_MIN,
		[MINC].[Skin Cancer] as SKIN_CANCER_MIN_CODE,
		[MIN].[Other Cancers] as OTHER_CANCERS_MIN,
		[MINC].[Other Cancers] as OTHER_CANCERS_MIN_CODE,
		[MIN].Schizophrenia as SCHIZOPHRENIA_MIN,
		[MINC].Schizophrenia as SCHIZOPHRENIA_MIN_CODE,
		[MIN].[Bipolar Affective Disorder] as BIPOLAR_MIN,
		[MINC].[Bipolar Affective Disorder] as BIPOLAR_MIN_CODE,
		[MIN].[Other Psychosis] as OTHER_PSYCHOSIS_MIN,
		[MINC].[Other Psychosis] as OTHER_PSYCHOSIS_MIN_CODE,
		[MIN].Dementia as DEMENTIA_MIN,
		[MINC].Dementia as DEMENTIA_MIN_CODE,
		[MIN].Depression as DERPRESSION_MIN,
		[MINC].Depression as DERPRESSION_MIN_CODE,
		[MIN].Anxiety as ANXIETY_MIN,
		[MINC].Anxiety  as ANXIETY_MIN_CODE,
		[MIN].[Palliative Care Register/End of Life Care Register] as PALLIATIVE_EOL_MIN,
		[MINC].[Palliative Care Register/End of Life Care Register] as PALLIATIVE_EOL_MIN_CODE,
		[MIN].[Pulmonary Embolism] as PULMONARY_EMBOLISM_MIN,
		[MINC].[Pulmonary Embolism] as PULMONARY_EMBOLISM_MIN_CODE,
		[MIN].[Learning Disabilities] as LEARNING_DISABILITIES_MIN,
		[MINC].[Learning Disabilities] as LEARNING_DISABILITIES_MIN_CODE,
		[MIN].Dysphagia as DYSPHAGIA_MIN,
		[MINC].Dysphagia as DYSPHAGIA_MIN_CODE,
		[MIN].Autism as AUTISM_MIN,
		[MINC].Autism as AUTISM_MIN_CODE,
		[MIN].[Psychoactive Substance Misuse Disorder] as PSYCHOACTIVE_SUBSTANCE_MISUSE_MIN,
		[MINC].[Psychoactive Substance Misuse Disorder] as PSYCHOACTIVE_SUBSTANCE_MISUSE_MIN_CODE,
		[MIN].[Psychotic Disorder] as PSYCHOTIC_DISORDER_MIN,
		[MINC].[Psychotic Disorder] as PSYCHOTIC_DISORDER_MIN_CODE,
		[MIN].[Age-related Macular Degeneration] as AGE_RELATED_MACULAR_DEGEN_MIN,
		[MINC].[Age-related Macular Degeneration] as AGE_RELATED_MACULAR_DEGEN_MIN_CODE,
		[MIN].[Primary Open-Angle Glaucoma] as PRIMARY_OA_GLAUCOMA_MIN,
		[MINC].[Primary Open-Angle Glaucoma] as PRIMARY_OA_GLAUCOMA_MIN_CODE,
		[MIN].[Blind] as BLIND_MIN,
		[MINC].[Blind] as BLIND_MIN_CODE,
		[MIN].[Partially Sighted] as PARTIALLY_SIGHTED_MIN,
		[MINC].[Partially Sighted] as PARTIALLY_SIGHTED_MIN_CODE,
		[MIN].[Hearing Impaired] as HEARING_IMPAIRED_MIN,
		[MINC].[Hearing Impaired] as HEARING_IMPAIRED_MIN_CODE,
		[MIN].[Neurosis] as NEUROSIS_MIN,
		[MINC].[Neurosis] as NEUROSIS_MIN_CODE,
		[MIN].[Poisoning] as POISONING_MIN,
		[MINC].[Poisoning] as POISONING_MIN_CODE,
		[MIN].[Sprain] as SPRAIN_MIN,
		[MINC].[Sprain] as SPRAIN_MIN_CODE,
		[MIN].[Mental disorder] as MENTAL_DISORDER_MIN,
		[MINC].[Mental disorder] as MENTAL_DISORDER_MIN_CODE,
		[MIN].[Gastro-intestinal disorder] as GASTROINTESTINAL_DISORDER_MIN,
		[MINC].[Gastro-intestinal disorder] as GASTROINTESTINAL_DISORDER_MIN_CODE,
		[MIN].[Frailty] as FRAILTY_MIN,
		[MIN].[Frailty] as FRAILTY_MIN_VALUE_DATE,
		[MINV].[Frailty] as FRAILTY_MIN_VALUE,
		[MINC].[Frailty] as FRAILTY_MIN_CODE,
		[MIN].[Chronic pain] as CHRONIC_PAIN_MIN,
		[MINC].[Chronic pain] as CHRONIC_PAIN_MIN_CODE,
		[MIN].[Parkinsons disease] as PARKINSONS_DISEASE_MIN,
		[MINC].[Parkinsons disease] as PARKINSONS_DISEASE_MIN_CODE,
		[MIN].[Multiple sclerosis] as MULTIPLE_SCLEROSIS_MIN,
		[MINC].[Multiple sclerosis] as MULTIPLE_SCLEROSIS_MIN_CODE,
		[MIN].[Motor neurone disease] as MOTOR_NEURONE_DISEASE_MIN,
		[MINC].[Motor neurone disease] as MOTOR_NEURONE_DISEASE_MIN_CODE,
		[MIN].[Respiratory failure] as RESPIRATORY_FAILURE_MIN,
		[MINC].[Respiratory failure] as RESPIRATORY_FAILURE_MIN_CODE,
		[MIN].[Kidney failure] as KIDNEY_FAILURE_MIN,
		[MINC].[Kidney failure] as KIDNEY_FAILURE_MIN_CODE,
		[MIN].[Osteoporosis] as OSTEOPOROSIS_MIN,
		[MINC].[Osteoporosis] as OSTEOPOROSIS_MIN_CODE,
		[MIN].[Osteoarthritis] as OSTEOARTHRITIS_MIN,
		[MINC].[Osteoarthritis] as OSTEOARTHRITIS_MIN_CODE,
		[MIN].[Rheumatoid arthritis] as RHEUMATOID_ARTHRITIS_MIN,
		[MINC].[Rheumatoid arthritis] as RHEUMATOID_ARTHRITIS_MIN_CODE,
		[MIN].[Ankylosing spondylitis] as ANKYLOSING_SPONDYLITIS_MIN,
		[MINC].[Ankylosing spondylitis] as ANKYLOSING_SPONDYLITIS_MIN_CODE,
		[MIN].[Spondylosis and allied disorders] as SPONDYLOSIS_AND_ALLIED_DISORDERS_MIN,
		[MINC].[Spondylosis and allied disorders] as SPONDYLOSIS_AND_ALLIED_DISORDERS_MIN_CODE,
		[MIN].[Lupus] as LUPUS_MIN,
		[MINC].[Lupus] as LUPUS_MIN_CODE,
		[MIN].[Fibromyalgia] as FIBROMYALGIA_MIN,
		[MINC].[Fibromyalgia] as FIBROMYALGIA_MIN_CODE,
		[MIN].[Gout] as GOUT_MIN,
		[MINC].[Gout] as GOUT_MIN_CODE,
		[MIN].[Reactive Septic arthritis] as REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MIN,
		[MINC].[Reactive Septic arthritis] as REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MIN_CODE,
		[MIN].[Psoriatic arthritis] as PSORIATIC_ARTHRITIS_MIN,
		[MINC].[Psoriatic arthritis] as PSORIATIC_ARTHRITIS_MIN_CODE,
		[MIN].[Osteomalacia] as OSTEOMALACIA_MIN,
		[MINC].[Osteomalacia] as OSTEOMALACIA_MIN_CODE,
		[MIN].[Polymyositis] as POLYMYOSITIS_MIN,
		[MINC].[Polymyositis] as POLYMYOSITIS_MIN_CODE,
		[MIN].[Polymyalgia rheumatica] as POLYMYALGIA_RHEUMATICA_MIN,
		[MINC].[Polymyalgia rheumatica] as POLYMYALGIA_RHEUMATICA_MIN_CODE,
		[MIN].[Sicca (Sjogrens) syndrome] as SJOGRENS_SYNDROME_MIN,
		[MINC].[Sicca (Sjogrens) syndrome] as SJOGRENS_SYNDROME_MIN_CODE,
		[MIN].[Scleroderma] as SCLERODERMA_MIN,
		[MINC].[Scleroderma] as SCLERODERMA_MIN_CODE,
		[MIN].[Tendonitis] as TENDONITIS_MIN,
		[MINC].[Tendonitis] as TENDONITIS_MIN_CODE,
		[MIN].[Familial Hypercholesterolaemia] as FAMILIAL_HYPERCHOLESTEROLAEMIA_MIN,
		[MINC].[Familial Hypercholesterolaemia] as FAMILIAL_HYPERCHOLESTEROLAEMIA_MIN_CODE,
		[MIN].[Crohns disease] as CROHNS_DISEASE_MIN,
		[MINC].[Crohns disease] as CROHNS_DISEASE_MIN_CODE,
		[MIN].[Coeliac disease] as COELIAC_DISEASE_MIN,
		[MINC].[Coeliac disease] as COELIAC_DISEASE_MIN_CODE,
		[MIN].[Ulcerative colitis] as ULCERATIVE_COLITIS_MIN,
		[MINC].[Ulcerative colitis] as ULCERATIVE_COLITIS_MIN_CODE,
		[MIN].[Inflammatory bowel disease] as INFLAMMATORY_BOWEL_DISEASE_MIN,
		[MINC].[Inflammatory bowel disease] as INFLAMMATORY_BOWEL_DISEASE_MIN_CODE,
		[MIN].[Diverticulitis] as DIVERTICULITIS_MIN,
		[MINC].[Diverticulitis] as DIVERTICULITIS_MIN_CODE,
		[MIN].[Diverticulosis] as DIVERTICULOSIS_MIN,
		[MINC].[Diverticulosis] as DIVERTICULOSIS_MIN_CODE,
		[MIN].[Barretts oesophagus] as BARRETTS_OESOPHAGUS_MIN,
		[MINC].[Barretts oesophagus] as BARRETTS_OESOPHAGUS_MIN_CODE,
		[MIN].[Physical Disability] as PHYSICAL_DISABILITY_MIN,
		[MINC].[Physical Disability] as PHYSICAL_DISABILITY_MIN_CODE,
		[MIN].[Cholesterol] as CHOLESTEROL_MIN,
		[MINV].[Cholesterol] as CHOLESTEROL_MIN_VALUE,
		[MIN].[Cholesterol (non-values)] as CHOLESTEROL_NONVALUES_MIN,
		[MINC].[Cholesterol (non-values)] as CHOLESTEROL_NONVALUES_MIN_CODE,
		[MIN].[HDL Cholesterol] as HDL_CHOLESTEROL_MIN,
		[MINV].[HDL Cholesterol] as HDL_CHOLESTEROL_MIN_VALUE,
		[MIN].[LDL Cholesterol] as LDL_CHOLESTEROL_MIN,
		[MINV].[LDL Cholesterol] as LDL_CHOLESTEROL_MIN_VALUE,
		[MIN].[BP Diastolic] as BP_DIASTOLIC_MIN,
		[MINV].[BP Diastolic] as BP_DIASTOLIC_MIN_VALUE,
		[MIN].[BP Systolic] as BP_SYSTOLIC_MIN,
		[MINV].[BP Systolic] as BP_SYSTOLIC_MIN_VALUE,
		[MIN].[BMI] as BMI_MIN,
		[MINV].[BMI] as BMI_MIN_VALUE,
		[MIN].[HbA1C] as HbA1C_MIN,
		[MINV].[HbA1C] as HbA1C_MIN_VALUE,
		[MIN].[HbA1C (non-values) Code] as HBA1C_NONVALUES_CODE_MIN,
		[MINC].[HbA1C (non-values) Code] as HBA1C_NONVALUES_CODE_MIN_CODE,
		[MIN].[eGFR] as eGFR_MIN,
		[MINV].[eGFR] as eGFR_MIN_VALUE,
		[MIN].[FEV1/FVC] as FEV1_FVC_MIN,
		[MINV].[FEV1/FVC] as FEV1_FVC_MIN_VALUE,
		[MIN].[Microalbuminuria (Code)] as MICROALBUMINURIA_MIN,
		[MINV].[Microalbuminuria (Code)] as MICROALBUMINURIA_MIN_VALUE,
		[MIN].[Microalbuminuria Code] as MICROALBUMINURIA_CODE_MIN,
		[MINC].[Microalbuminuria Code] as MICROALBUMINURIA_CODE_MIN_CODE,
		[MIN].[Albuminuria (ACR)] as ACR_MIN,
		[MINV].[Albuminuria (ACR)] as ACR_MIN_VALUE,
		[MIN].[Alcohol Consumption] as ALCOHOL_CONSUMPTION_MIN,
		[MINC].[Alcohol Consumption] as ALCOHOL_CONSUMPTION_MIN_CODE,
		[MIN].[Alcohol Status] as ALCOHOL_STATUS_MIN,
		[MINC].[Alcohol Status] as ALCOHOL_STATUS_MIN_CODE,
		[MIN].[Alcohol advice] as ALCOHOL_ADVICE_MIN,
		[MINC].[Alcohol advice] as ALCOHOL_ADVICE_MIN_CODE,
		[MIN].[Brief Intervention (alcohol)] as BRIEF_INTERVENTION_ALCOHOL_MIN,
		[MINC].[Brief Intervention (alcohol)] as BRIEF_INTERV_ALCOHOL_MIN_CODE,
		[MIN].[Spirometry] as SPIROMETRY_MIN,
		[MINV].[Spirometry] as SPIROMETRY_MIN_VALUE,
		[MIN].[Qrisk Score] as QRISK_SCORE_MIN,
		[MINV].[Qrisk Score] as QRISK_SCORE_MIN_VALUE,
		[MIN].[Framingham Score] as FRAMINGHAM_SCORE_MIN,
		[MINV].[Framingham Score] as FRAMINGHAM_SCORE_MIN_VALUE,
		[MIN].[JBS Risk Score] as JBS_RISK_SCORE_MIN,
		[MINC].[JBS Risk Score] as JBS_RISK_SCORE_MIN_CODE,
		
		[MIN].[Pulse Rate] as PULSE_RATE_MIN,
		[MINV].[Pulse Rate] as PULSE_RATE_MIN_VALUE,
		[MINC].[Pulse Rate] as PULSE_RATE_MIN_CODE,

		[MIN].[Creatinine (All in last 1 year)] as CREATININE_MIN,
		[MINV].[Creatinine (All in last 1 year)] as CREATININE_MIN_VALUE,
		[MIN].[Urine Protein Test] as URINE_PROTEIN_TEST_MIN,
		[MINV].[Urine Protein Test] as URINE_PROTEIN_TEST_VALUE_MIN,
		[MIN].[Proteinuria] as PROTEINURIA_MIN,
		[MINC].[Proteinuria] as PROTEINURIA_MIN_CODE,
		[MIN].[CHA2DS2 VASC] as CHA2DS2_VASC_MIN,
		[MINV].[CHA2DS2 VASC] as CHA2DS2_VASC_VALUE_MIN,
		[MIN].[SERUM ALBUMIN] as SERUM_ALBUMIN_MIN,
		[MINV].[SERUM ALBUMIN] as SERUM_ALBUMIN_VALUE_MIN,
		[MIN].[TOTAL BILIRUBIN] as TOTAL_BILIRUBIN_MIN,
		[MINV].[TOTAL BILIRUBIN] as TOTAL_BILIRUBIN_VALUE_MIN,
		[MIN].[PROTHROMBIN TIME / INR] as PROTHROMBIN_TIME_INR_MIN,
		[MINV].[PROTHROMBIN TIME / INR] as PROTHROMBIN_TIME_INR_VALUE_MIN,
		[MIN].[Smoking Status] as SMOKING_STATUS_MIN,
		[MINC].[Smoking Status] as SMOKING_STATUS_MIN_CODE,
		[MIN].[Pulse Rhythm] as PULSE_RHYTHM_MIN,
		[MINC].[Pulse Rhythm] as PULSE_RHYTHM_MIN_CODE,
		[MIN].[MRC Breathless Scale] as MRC_BREATHLESS_SCALE_MIN,
		[MINC].[MRC Breathless Scale] as MRC_BREATHLESS_SCALE_MIN_CODE,
		[MIN].[Asthma Severity] as ASTHMA_SEVERITY_MIN,
		[MINC].[Asthma Severity] as ASTHMA_SEVERITY_MIN_CODE,
		[MIN].[Asthma Control Steps] as ASTHMA_CONTROL_STEPS_MIN,
		[MINC].[Asthma Control Steps] as ASTHMA_CONTROL_STEPS_MIN_CODE,
		[MIN].[Heart Failure diagnosed via echocardiogram] as HEART_FAILURE_DIAG_ECHOCARDIOGRAM_MIN,
		[MINC].[Heart Failure diagnosed via echocardiogram] as HEART_FAILURE_DIAG_ECHOCARDIOGRAM_MIN_CODE,
		[MIN].[Smoking cessation advice] as SMOKING_CESSATION_ADVICE_MIN,
		[MINC].[Smoking cessation advice] as SMOKING_CESSATION_ADVICE_MIN_CODE,
		[MIN].[Referral to Smoking Cessation Clinic] as REFERRAL_TO_SMOKING_CESSATION_CLINIC_MIN,
		[MINC].[Referral to Smoking Cessation Clinic] as REFERRAL_TO_SMOKING_CESSATION_CLINIC_MIN_CODE,
		[MIN].[DNA Smoking Cessation Clinic] as DNA_SMOKING_CESSATION_CLINIC_MIN,
		[MINC].[DNA Smoking Cessation Clinic] as DNA_SMOKING_CESSATION_CLINIC_MIN_CODE,
		[MIN].[Exercise Advice] as EXERCISE_ADVICE_MIN,
		[MINC].[Exercise Advice] as EXERCISE_ADVICE_MIN_CODE,
		[MIN].[Diet Advice] as DIET_ADVICE_MIN,
		[MINC].[Diet Advice] as DIET_ADVICE_MIN_CODE,
		[MIN].[Mental Health Care plan] as MENTAL_HEALTH_CARE_PLAN_MIN,
		[MINC].[Mental Health Care plan] as MENTAL_HEALTH_CARE_PLAN_MIN_CODE,
		[MIN].[Referral to Pulmonary rehabilitation] as REFERRAL_TO_PULMONARY_REHAB_MIN,
		[MINC].[Referral to Pulmonary rehabilitation] as REFERRAL_TO_PULMONARY_REHAB_MIN_CODE,
		[MIN].[Pulmonary rehabilitation programme commenced] as PULMONARY_REHAB_PROGRAMME_COMMENCED_MIN,
		[MINC].[Pulmonary rehabilitation programme commenced] as PULMONARY_REHAB_PROGRAMME_COMMENCED_MIN_CODE,
		[MIN].[Pulmonary rehabilitation programme completed] as PULMONARY_REHAB_PROGRAMME_COMPLETED_MIN,
		[MINC].[Pulmonary rehabilitation programme completed] as PULMONARY_REHAB_PROGRAMME_COMPLETED_MIN_CODE,
		[MIN].[COPD Self management Plan] as COPD_SELF_MANAGEMENT_PLAN_MIN,
		[MINC].[COPD Self management Plan] as COPD_SELF_MANAGEMENT_PLAN_MIN_CODE,
		[MIN].[COPD Rescue Pack] as COPD_RESCUE_PACK_MIN,
		[MINC].[COPD Rescue Pack] as COPD_RESCUE_PACK_MIN_CODE,
		[MIN].[Offered Structured Education (Diabetes)] as OFFERED_STRUCTURED_EDUCAT_DIABETES_MIN,
		[MINC].[Offered Structured Education (Diabetes)] as OFFERED_STRUCTURED_EDUCAT_DIABETES_MIN_CODE,
		[MIN].[Attended Structured Education (Diabetes)] as ATTENDED_STRUCTURED_EDUCAT_DIABETES_MIN,
		[MINC].[Attended Structured Education (Diabetes)] as ATTENDED_STRUCTURED_EDUCAT_DIABETES_MIN_CODE,
		[MIN].[Completed Structured Education (DIabetes)] as COMPLETED_STRUCTURED_EDUCAT_DIABETES_MIN,
		[MINC].[Completed Structured Education (DIabetes)] as COMPLETED_STRUCTURED_EDUCAT_DIABETES_MIN_CODE,
		[MIN].[Insulin Passport] as INSULIN_PASSPORT_MIN,
		[MINC].[Insulin Passport] as INSULIN_PASSPORT_MIN_CODE,
		[MIN].[Referred to cardiac rehabilitation] as REFERRED_TO_CARDIAC_REHABILITATION_MIN,
		[MINC].[Referred to cardiac rehabilitation] as REFERRED_TO_CARDIAC_REHABILITATION_MIN_CODE,
		[MIN].[Cardiac rehabilitation declined] as CARDIAC_REHABILITATION_DECLINED_MIN,
		[MINC].[Cardiac rehabilitation declined] as CARDIAC_REHABILITATION_DECLINED_MIN_CODE,
		[MIN].[Cardiac rehabilitation] as CARDIAC_REHABILITATION_MIN,
		[MINC].[Cardiac rehabilitation] as CARDIAC_REHABILITATION_MIN_CODE,
		[MIN].[Cardiac Rehabilitation Completed] as CARDIAC_REHABILITATION_COMPLETED_MIN,
		[MINC].[Cardiac Rehabilitation Completed] as CARDIAC_REHABILITATION_COMPLETED_MIN_CODE,
		[MIN].[Diabetes review (Annual)] as DIABETES_REVIEW_ANNUAL_MIN,
		[MINC].[Diabetes review (Annual)] as DIABETES_REVIEW_ANNUAL_MIN_CODE,
		[MIN].[Diabetes review (Other)] as DIABETES_REVIEW_OTHER_MIN,
		[MINC].[Diabetes review (Other)] as DIABETES_REVIEW_OTHER_MIN_CODE,
		[MIN].[Diabetes Care setting] as DIABETES_CARE_SETTING_MIN,
		[MINC].[Diabetes Care setting] as DIABETES_CARE_SETTING_MIN_CODE,
		[MIN].[Referred to Dietician] as REFERRED_TO_DIETICIAN_MIN,
		[MINC].[Referred to Dietician] as REFERRED_TO_DIETICIAN_MIN_CODE,
		[MIN].[Diabetic foot review] as DIABETIC_FOOT_REVIEW_MIN,
		[MINC].[Diabetic foot review] as DIABETIC_FOOT_REVIEW_MIN_CODE,
		[MIN].[Diabetic Neuropathy testing] as DIABETIC_NEUROPATHY_TESTING_MIN,
		[MINC].[Diabetic Neuropathy testing] as DIABETIC_NEUROPATHY_TESTING_MIN_CODE,
		[MIN].[CHD review] as CHD_REVIEW_MIN,
		[MINC].[CHD review] as CHD_REVIEW_MIN_CODE,
		[MIN].[Medication Review] as MEDICATION_REVIEW_MIN,
		[MINC].[Medication Review] as MEDICATION_REVIEW_MIN_CODE,
		[MIN].[Medication Review Declined] as MEDICATION_REVIEW_DECLINED_MIN,
		[MINC].[Medication Review Declined] as MEDICATION_REVIEW_DECLINED_MIN_CODE,
		[MIN].[COPD Annual Review] as COPD_ANNUAL_REVIEW_MIN,
		[MINC].[COPD Annual Review] as COPD_ANNUAL_REVIEW_MIN_CODE,
		[MIN].[Heart Failure review] as HEART_FAILURE_REVIEW_MIN,
		[MINC].[Heart Failure review] as HEART_FAILURE_REVIEW_MIN_CODE,
		[MIN].[Mental Health Review] as MENTAL_HEALTH_REVIEW_MIN,
		[MINC].[Mental Health Review] as MENTAL_HEALTH_REVIEW_MIN_CODE,
		[MIN].[Dementia Review] as DEMENTIA_REVIEW_MIN,
		[MINC].[Dementia Review] as DEMENTIA_REVIEW_MIN_CODE,
		[MIN].[Depression review] as DEPRESSION_REVIEW_MIN,
		[MINC].[Depression review] as DEPRESSION_REVIEW_MIN_CODE,
		[MIN].[Depression screening/questionnaire] as DEPRESSION_SCREENING_MIN,
		[MINC].[Depression screening/questionnaire] as DEPRESSION_SCREENING_MIN_CODE,
		[MIN].[Bowel Screening] as BOWEL_SCREENING_MIN,
		[MINC].[Bowel Screening] as BOWEL_SCREENING_MIN_CODE,
		[MIN].[Bowel Screening Declined] as BOWEL_SCREENING_DECLINED_MIN,
		[MINC].[Bowel Screening Declined] as BOWEL_SCREENING_DECLINED_MIN_CODE,
		[MIN].[NHS Health Checks] as NHS_HEALTH_CHECKS_MIN,
		[MINC].[NHS Health Checks] as NHS_HEALTH_CHECKS_MIN_CODE,
		[MIN].[Cervical Screening] as CERVICAL_SCREENING_MIN,
		[MINC].[Cervical Screening] as CERVICAL_SCREENING_MIN_CODE,
		[MIN].[Learning Disabilities Health Assessment] as LEARNING_DISABILITIES_HEALTH_ASSESSMENT_MIN,
		[MINC].[Learning Disabilities Health Assessment] as LEARNING_DISABILITIES_HEALTH_ASSESSMENT_MIN_CODE,
		[MIN].[DNA Bowel cancer screening] as DNA_BOWEL_CANCER_SCREENING_MIN,
		[MINC].[DNA Bowel cancer screening] as DNA_BOWEL_CANCER_SCREENING_MIN_CODE,
		[MIN].[CVD Risk assessment declined] as CVD_RISK_ASSESSMENT_DECLINED_MIN,
		[MINC].[CVD Risk assessment declined] as CVD_RISK_ASSESSMENT_DECLINED_MIN_CODE,
		[MIN].[DNA NHS Health Check] as DNA_NHS_HEALTH_CHECK_MIN,
		[MINC].[DNA NHS Health Check] as DNA_NHS_HEALTH_CHECK_MIN_CODE,
		[MIN].[Diabetic Retinal Screening � needs checking] as DIABETIC_RETINAL_SCREENING_MIN,
		[MINC].[Diabetic Retinal Screening � needs checking] as DIABETIC_RETINAL_SCREENING_MIN_CODE,
		[MIN].[Cervical cytology exceptions] as CERVICAL_CYTOLOGY_EXCEPTIONS_MIN,
		[MINC].[Cervical cytology exceptions] as CERVICAL_CYTOLOGY_EXCEPTIONS_MIN_CODE,
		[MIN].[Hysterectomy and equivalent ] as HYSTERECTOMY_AND_EQUIVALENT_MIN,
		[MINC].[Hysterectomy and equivalent ] as HYSTERECTOMY_AND_EQUIVALENT_MIN_CODE,
		[MIN].[Spirometry contraindicated/declined] as SPIROMETRY_CONTRAINDICATED_DECLINED_MIN,
		[MINC].[Spirometry contraindicated/declined] as SPIROMETRY_CONTRAINDICATED_DECLINED_MIN_CODE,
		[MIN].[ACE / A2RA MIN Tolerated Dose] as ACE_A2RA_MIN_TOLERATED_DOSE_MIN,
		[MINC].[ACE / A2RA MIN Tolerated Dose] as ACE_A2RA_MIN_TOLERATED_DOSE_MIN_CODE
		,[MIN].[Attention Deficit Hyperactivity Disorder] as [Attention_Deficit_Hyperactivity_Disorder_MIN]
		,[MINC].[Attention Deficit Hyperactivity Disorder] AS [Attention_Deficit_Hyperactivity_Disorder_MIN_CODE]
		,[MIN].[Frailty Index] as [Frailty_Index_MIN]
		,[MINC].[Frailty Index] as [Frailty_Index_MIN_CODE]
		,[MIN].[Lymphoedema] as [Lymphoedema_MIN]
		,[MINC].[Lymphoedema] as [Lymphoedema_MIN_CODE]
		,[MIN].[Homeless] as [Homeless_MIN]
		,[MINC].[Homeless] as [Homeless_MIN_CODE]
		,[MIN].Carer as [Carer_MIN]
		,[MINC].Carer as [Carer_MIN_CODE]
		,[MIN].[Asylum Seeker] as [Asylum_Seeker_MIN]
		,[MINC].[Asylum Seeker] as [Asylum_Seeker_MIN_CODE]
		,[MIN].[Suicide and Self Harm] as SelfHarm_MIN
		,[MINC].[Suicide and Self Harm] as SelfHarm_MIN_CODE


into Client_SystemP_RW.RP102_Conditions                                
from Client_SystemP_RW.RP001_MPI as MPI 
      LEFT JOIN #MAX_DATE MAX ON MPI.Pseudo_NHS_Number collate database_default = MAX.Pseudo_NHS_Number collate database_default
      LEFT JOIN #MAX_CODE MAXC ON MPI.Pseudo_NHS_Number collate database_default = MAXC.Pseudo_NHS_Number collate database_default
      LEFT JOIN #MAX_VALUE MAXV ON MPI.Pseudo_NHS_Number collate database_default = MAXV.Pseudo_NHS_Number collate database_default
	  LEFT JOIN #MIN_DATE MIN ON MPI.Pseudo_NHS_Number collate database_default = MIN.Pseudo_NHS_Number collate database_default
      LEFT JOIN #MIN_CODE MINC ON MPI.Pseudo_NHS_Number collate database_default = MINC.Pseudo_NHS_Number collate database_default
      LEFT JOIN #MIN_VALUE MINV ON MPI.Pseudo_NHS_Number collate database_default = MINV.Pseudo_NHS_Number collate database_default




	  