/****** This code is based on Justine Wiltshire code
******/

/*** Updates author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------
/* creates labels corresponding to super-groups or segments using the conditions in the conditions table */
---------------------------------------------------------------------------------------------------------------------------------------------
/* the segments are based on bridges to health model  */
/* additional segments are based on social conditions */

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


drop table if exists Client_SystemP_RW.RP103_Segmentation
select Pseudo_NHS_Number
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
	,FrailtyLevel
	,TotalHousehold
	,LivingAlone
	,LivingWithUnder18
	,UPRNMatch
	,case when Homeless_MAX_CODE is not null and Homeless_MAX>CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102) then 1 else 0 end as Homeless
	,case when Carer_MAX_CODE is not null and Carer_MAX>CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102) then 1 else 0 end as Carer
	,case when Asylum_Seeker_MAX_CODE is not null then 1 else 0 end as AsylumSeeker
	,case when SelfHarm_MAX_CODE is not null and SelfHarm_MAX>CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102) then 1 else 0 end as SelfHarm
	,case when Smoking_Status_MAX_CODE is not null and Smoking_Status_MAX>CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102) then 1 else 0 end as Smoker
	,0 as H_abuse
	,0 as offender
	,0 as Substance_or_alcohol
	,0 as Alcohol
	,0 as substance
	,0 as freq_ae_attend
	,0 as h_looked_after
	,0 as FlagAC
	,0 as ACTotal
	,0 as Falls

	--END OF LIFE FLAG-----------------------------------------------------------------------------
	,case when [PALLIATIVE_EOL_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102) then 1 else 0 end as [Palliative_EOL_Reg]

	--FRAILTY OR DEMENTIA FLAG---------------------------------------------------------------------
	,case when FrailtyLevel in ('Moderate','Severe') then 1
		when [DEMENTIA_MAX_CODE] is not null then 1 else 0 end as [Frailty_or_Dementia]

	--COMPLEX LIVES FLAG---------------------------------------------------------------------------
	,Complex = 0

	--CANCER FLAG----------------------------------------------------------------------------------
	--basically i must have moved this from detail section
	,case when ([BLADDER_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1   
		when ([BREAST_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1     
		when ([CERVICAL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1   
		when ([BOWEL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1     
		when ([PROSTATE_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1  
		when ([SKIN_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1        
		when ([OTHER_CANCERS_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Cancer]

	--LONG TERM CONDITIONS FLAG--------------------------------------------------------------------
			-- Cancer
			,case when ([BLADDER_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1   
				when ([BREAST_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1     
				when ([CERVICAL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1   
				when ([BOWEL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1     
				when ([PROSTATE_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1  
				when ([SKIN_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1        
				when ([OTHER_CANCERS_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1    

			-- Diabetes
				when (([DIABETES_MAX_CODE] is not null) and [DIABETES_MAX_CODE] not in ('315051004')) --diabetes resolved, was ('21263','212H')
					and ([IGR_MAX] is null or [DIABETES_MAX] is null or (IGR_MAX <= [DIABETES_MAX])) then 1
	
			--Gastro
				when ([CROHNS_DISEASE_MAX_CODE] is not null) then 1    
				when ([COELIAC_DISEASE_MAX_CODE] is not null) then 1
				when ([ULCERATIVE_COLITIS_MAX_CODE] is not null) then 1
				when ([INFLAMMATORY_BOWEL_DISEASE_MAX_CODE] is not null) then 1
				when ([DIVERTICULITIS_MAX_CODE] is not null) then 1
				when ([DIVERTICULOSIS_MAX_CODE] is not null) then 1
				when ([BARRETTS_OESOPHAGUS_MAX_CODE] is not null) then 1

			--CVD
				when ([CHD_MAX_CODE] is not null) then 1
				when ([STROKE_MAX_CODE] is not null) then 1
				when ([TIA_MAX_CODE] is not null) then 1
				when ([PVD_PAD_MAX_CODE] is not null) then 1
				when ([MI_MAX_CODE] is not null) then 1
				when ([ANGINA_MAX_CODE] is not null) then 1
				when ([AF_MAX_CODE] is not null) and [AF_MAX_CODE] not in ('196371000000102') then 1 --resolved is their exclusion, was ('212R')
				
			--HF
				when ([HF_MAX_CODE] is not null) then 1
			
			--Epilepsy
				when ([EPILEPSY_MAX_CODE] is not null)  then 1
			
			--CKD
				when ([CKD_MAX_CODE] is not null) and [CKD_MAX_CODE] not in ('431855005','431856006','324211000000106','324151000000104','324121000000109','324181000000105') then 1 

			--CMHP aggregate

			--Depression
				when ([DERPRESSION_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1

			--Anxiety        
				when ([ANXIETY_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1

			--SMI aggregate

			-- Schizophrenia
				when [SCHIZOPHRENIA_MAX_CODE] is not null then 1

			--Bipolar
				when [BIPOLAR_MAX_CODE] is not null then 1

			-- Other psychosis
				when [OTHER_PSYCHOSIS_MAX_CODE] is not null then 1

			--Psychotic disorder
				when [PSYCHOTIC_DISORDER_MAX_CODE] is not null then 1

			--Rheumatology
				when ([OSTEOPOROSIS_MAX_CODE] is not null) then 1
				when ([OSTEOARTHRITIS_MAX_CODE] is not null) then 1
				when ([RHEUMATOID_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([ANKYLOSING_SPONDYLITIS_MAX_CODE] is not null) then 1
				when ([SPONDYLOSIS_AND_ALLIED_DISORDERS_MAX_CODE] is not null) then 1
				when ([LUPUS_MAX_CODE] is not null) then 1
				when ([FIBROMYALGIA_MAX_CODE] is not null) then 1
				when ([GOUT_MAX_CODE] is not null) then 1
				when ([REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([PSORIATIC_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([OSTEOMALACIA_MAX_CODE] is not null) then 1
				when ([POLYMYOSITIS_MAX_CODE] is not null) then 1
				when ([POLYMYALGIA_RHEUMATICA_MAX_CODE] is not null) then 1
				when ([SJOGRENS_SYNDROME_MAX_CODE] is not null) then 1
				when ([SCLERODERMA_MAX_CODE] is not null) then 1
				when ([TENDONITIS_MAX_CODE] is not null) then 1

			--Asthma
				when ([ASTHMA_MAX_CODE] is not null) then 1

			--COPD
				when ([COPD_MAX_CODE] is not null) then 1

			--Neuro
				when ([PARKINSONS_DISEASE_MAX_CODE] is not null) then 1
				when ([MULTIPLE_SCLEROSIS_MAX_CODE] is not null) then 1
				when ([MOTOR_NEURONE_DISEASE_MAX_CODE] is not null) then 1	else 0 end as LTC

	--PRE CONDITIONS FLAG--------------------------------------------------------------------------
	,case when [IGR_MAX_CODE] is not null and ([DIABETES_MAX_CODE] is null or ([DIABETES_MAX] < IGR_MAX and [DIABETES_MAX] is not null)) then 1  
		when [HYPERTENSION_MAX_CODE] is not null and [HYPERTENSION_MAX_CODE] not in ('162659009') then 1 else 0 end as [Precondition]

	--LEARNING DISABILITIES FLAG-------------------------------------------------------------------
	,case when [LEARNING_DISABILITIES_MAX_CODE] is not null then 1	else 0 end as [Learning_Disabilities] 
	
	--PHYSICAL DISABILITY FLAG---------------------------------------------------------------------
	,case when [BLIND_MAX] is not null then 1
		when [PARTIALLY_SIGHTED_MAX] is not null then 1
		when [HEARING_IMPAIRED_MAX] is not null then 1
		when [PHYSICAL_DISABILITY_MAX] is not null then 1 else 0 end as [Physical_Disability]

	--DETAIL SECTION-------------------------------------------------------------------------------
			/* ORGAN FAILURE NEEDS ATTENTION */ ----- RP
			--ORGAN FAILURE FLAG---------------------------------------------------------------------------
			,case 
				when [RESPIRATORY_FAILURE_MAX_CODE] is not null then 1
				when [KIDNEY_FAILURE_MAX_CODE] is not null then 1
				when ([CKD_MAX_CODE] is not null) and [CKD_MAX_CODE] not in ('431855005','431856006','324211000000106','324151000000104','324121000000109','324181000000105') then 1 
				 else 0 end as [Organ_Failure]
		
			--IGR
			,case when [IGR_MAX_CODE] is not null and ([DIABETES_MAX_Code] is null or ([DIABETES_MAX] < IGR_MAX and [DIABETES_MAX] is not null)) then 1 else 0 end as [IGR]

			--Hypertension
			,case when [HYPERTENSION_MAX_CODE] is not null and [HYPERTENSION_MAX_CODE] not in ('162659009') then 1 else 0 end as [Hypertension]

			--Bladder cancer
			,case when ([BLADDER_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Bladder_cancer]

			--Breast cancer
			,case when ([BREAST_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Breast_cancer]

			--Cervical cancer
			,case when ([CERVICAL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Cervical_cancer]

			--Bowel cancer
			,case when ([BOWEL_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Bowel_cancer]

			--Prostate cancer
			,case when ([PROSTATE_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Prostate_cancer]

			--Skin cancer
 			,case when ([SKIN_CANCER_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Skin_cancer]

			--Other cancer
			,case when ([OTHER_CANCERS_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Other_cancer]

			-- Diabetes
			,case when (([DIABETES_MAX_CODE] is not null) and [DIABETES_MAX_CODE] not in ('315051004')) 
				and ([IGR_MAX] is null or [diabetes_MAX] is null or (IGR_MAX <= [DIABETES_MAX] ) ) then 1 else 0 end as [Diabetes]

			--Gastro
			,case when ([CROHNS_DISEASE_MAX_CODE] is not null) then 1    
				when ([COELIAC_DISEASE_MAX_CODE] is not null) then 1
				when ([ULCERATIVE_COLITIS_MAX_CODE] is not null) then 1
				when ([INFLAMMATORY_BOWEL_DISEASE_MAX_CODE] is not null) then 1
				when ([DIVERTICULITIS_MAX_CODE] is not null) then 1
				when ([DIVERTICULOSIS_MAX_CODE] is not null) then 1
				when ([BARRETTS_OESOPHAGUS_MAX_CODE] is not null) then 1 else 0 end as [Gastroenterological]

			--Crohns
			,case when ([CROHNS_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Crohns]

			--Coeliac
			,case when ([COELIAC_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Coeliac]

			--Ulcerative_colitis
			,case when ([ULCERATIVE_COLITIS_MAX_CODE] is not null) then 1 else 0 end as [Ulcerative_colitis]

			--Inflammatory_bowel_disease
			,case when ([INFLAMMATORY_BOWEL_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Inflammatory_bowel_disease]

			--Diverticulitis
			,case when ([DIVERTICULITIS_MAX_CODE] is not null) then 1 else 0 end as [Diverticulitis]

			--Diverticulosis
			,case when ([DIVERTICULOSIS_MAX_CODE] is not null) then 1 else 0 end as [Diverticulosis]

			--Barretts_oesophagus
			,case when ([BARRETTS_OESOPHAGUS_MAX_CODE] is not null) then 1 else 0 end as [Barretts_oesophagus]

			--CVD
			,case when ([CHD_MAX_CODE] is not null) then 1
			      when ([HF_MAX_CODE] is not null) then 1
				when ([STROKE_MAX_CODE] is not null) then 1
				when ([TIA_MAX_CODE] is not null) then 1
				when ([PVD_PAD_MAX_CODE] is not null) then 1
				when ([MI_MAX_CODE] is not null) then 1
				when ([ANGINA_MAX_CODE] is not null) then 1
				when ([AF_MAX_CODE] is not null) and [AF_MAX_CODE] not in ('196371000000102') then 1 else 0 end as [CVD]

			--CHD
			,case when ([CHD_MAX_CODE] is not null) then 1 else 0 end as [CHD]

			--Stroke/TIA
			,case when ([STROKE_MAX_CODE] is not null) then 1 
				when ([TIA_MAX_CODE] is not null) then 1 else 0 end as [Stroke_TIA]

			--PVD
			,case when ([PVD_PAD_MAX_CODE] is not null) then 1 else 0 end as [PVD]

			--MI
			,case when ([MI_MAX_CODE] is not null) then 1 else 0 end as [MI]

			--Angina
			,case when ([ANGINA_MAX_CODE] is not null) then 1 else 0 end as [Angina]

			--AF
			,case when ([AF_MAX_CODE] is not null) and [AF_MAX_CODE] not in ('196371000000102') then 1 else 0 end as [AF]

			--HF
			,case when ([HF_MAX_CODE] is not null) then 1 else 0 end as [Heart_failure]

			--Epilepsy
			,case when ([EPILEPSY_MAX_CODE] is not null) then 1 else 0 end as [Epilepsy]

			--CKD
			,case when ([CKD_MAX_CODE] is not null) and [CKD_MAX_CODE] not in ('431855005','431856006','324211000000106','324151000000104','324121000000109','324181000000105') then 1 else 0 end as [CKD]

			--CLD added by me
			,case when [CLD_MAX_CODE] is not null then 1 else 0 end as [CLD]

			--CMHP
			,case when ([DERPRESSION_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) 
				or ([ANXIETY_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [CMHP]

			--Depression
			,case when ([DERPRESSION_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Depression]

			--Anxiety       
			,case when ([ANXIETY_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Anxiety]

			--SMI
			,case when [SCHIZOPHRENIA_MAX_CODE] is not null then 1
				when [BIPOLAR_MAX_CODE] is not null then 1
				when [OTHER_PSYCHOSIS_MAX_CODE] is not null then 1
				when [PSYCHOTIC_DISORDER_MAX_CODE] is not null then 1 else 0 end as [SMI]

			-- Schizophrenia
			,case when [SCHIZOPHRENIA_MAX_CODE] is not null then 1 else 0 end as [Schizophrenia]

			--Bipolar
			,case when [BIPOLAR_MAX_CODE] is not null then 1 else 0 end as [Bipolar]

			--Other psychosis
			,case when [OTHER_PSYCHOSIS_MAX_CODE] is not null then 1 else 0 end as [Other_Psychosis]

			--Psychotic disorder
			,case when [PSYCHOTIC_DISORDER_MAX_CODE] is not null then 1 else 0 end as [Psychotic_disorder] 

			--Rheumatology
			,case when ([OSTEOPOROSIS_MAX_CODE] is not null) then 1
				when ([OSTEOARTHRITIS_MAX_CODE] is not null) then 1
				when ([RHEUMATOID_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([ANKYLOSING_SPONDYLITIS_MAX_CODE] is not null) then 1
				when ([SPONDYLOSIS_AND_ALLIED_DISORDERS_MAX_CODE] is not null) then 1
				when ([LUPUS_MAX_CODE] is not null) then 1
				when ([FIBROMYALGIA_MAX_CODE] is not null) then 1
				when ([GOUT_MAX_CODE] is not null) then 1
				when ([REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([PSORIATIC_ARTHRITIS_MAX_CODE] is not null) then 1
				when ([OSTEOMALACIA_MAX_CODE] is not null) then 1
				when ([POLYMYOSITIS_MAX_CODE] is not null) then 1
				when ([POLYMYALGIA_RHEUMATICA_MAX_CODE] is not null) then 1
				when ([SJOGRENS_SYNDROME_MAX_CODE] is not null) then 1
				when ([SCLERODERMA_MAX_CODE] is not null) then 1
				when ([TENDONITIS_MAX_CODE] is not null) then 1 else 0 end as [Rheumatology]

			--Osteoporosis
			,case when ([OSTEOPOROSIS_MAX_CODE] is not null) then 1 else 0 end as [Osteoporosis]

			--Osteoarthritis
			,case when ([OSTEOARTHRITIS_MAX_CODE] is not null) then 1 else 0 end as [Osteoarthritis]

			--Rheumatoid arthritis
			,case when ([RHEUMATOID_ARTHRITIS_MAX_CODE] is not null) then 1 else 0 end as [Rheumatoid_arthritis]

			--Ankylosing spondylitis
			,case when ([ANKYLOSING_SPONDYLITIS_MAX_CODE] is not null) then 1 else 0 end as [Ankylosing_spondylitis]

			--spondylitis and allied disorders
			,case when ([SPONDYLOSIS_AND_ALLIED_DISORDERS_MAX_CODE] is not null) then 1  else 0 end as [Spondylitis_and_allied_disorders]

			--Lupus
			,case when ([LUPUS_MAX_CODE] is not null) then 1 else 0 end as [Lupus]
			 
			--Fibromyalgia
			,case when ([FIBROMYALGIA_MAX_CODE] is not null) then 1 else 0 end as [Fibromyalgia]

			--Gout
			,case when ([GOUT_MAX_CODE] is not null) then 1 else 0 end as [Gout]

			--reactive arthritis septic arthritis
			,case when ([REACTIVE_ARTHRITIS_SEPTIC_ARTHRITIS_MAX_CODE] is not null) then 1 else 0 end as [Reactive_arthritis_septic_arthritis] 

			--Psoriatic arthritis
			,case when ([PSORIATIC_ARTHRITIS_MAX_CODE] is not null) then 1 else 0 end as [Psoriatic_arthritis]

			--osteomalacia
			,case when ([OSTEOMALACIA_MAX_CODE] is not null) then 1 else 0 end as [Osteomalacia]

			--Polymyositis
			,case when ([POLYMYOSITIS_MAX_CODE] is not null) then 1 else 0 end as [Polymyositis]

			--Polymyalgia
			,case when ([POLYMYALGIA_RHEUMATICA_MAX_CODE] is not null) then 1 else 0 end as [Polymyalgia]

			--Sjogrens Syndrome
			,case when ([SJOGRENS_SYNDROME_MAX_CODE] is not null) then 1 else 0 end as [Sjogrens_syndrome]

			--Scleroderma
			,case when ([SCLERODERMA_MAX_CODE] is not null) then 1 else 0 end as [Scleroderma] 
			
			--Tendonitis
			,case when ([TENDONITIS_MAX_CODE] is not null) then 1 else 0 end as [Tendonitis]

 			--Asthma
			,case when ([ASTHMA_MAX_CODE] is not null) then 1 else 0 end as [Asthma]

			--COPD
			,case when ([COPD_MAX_CODE] is not null) then 1 else 0 end as [COPD]

			--Neurological
			,case when ([PARKINSONS_DISEASE_MAX_CODE] is not null) then 1
				when ([MULTIPLE_SCLEROSIS_MAX_CODE] is not null) then 1
				when ([MOTOR_NEURONE_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Neurological]

			--Parkinsons_disease
			,case when ([PARKINSONS_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Parkinsons_disease]

			--Multiple sclerosis
			,case when ([MULTIPLE_SCLEROSIS_MAX_CODE] is not null) then 1 else 0 end as [Multiple_sclerosis]

			--Motor_neurone_disease
			,case when ([MOTOR_NEURONE_DISEASE_MAX_CODE] is not null) then 1 else 0 end as [Motor_neurone_disease]

			-- Frailty
			,case when FrailtyLevel in ('Moderate','Severe') then 1	else 0 end as [Frailty]

			-- Dementia
			,case when [DEMENTIA_MAX_CODE] is not null then 1 else 0 end as [Dementia]

			--Substance
			,case when ([PSYCHOACTIVE_SUBSTANCE_MISUSE_MAX_CODE] is not null 
				and [PSYCHOACTIVE_SUBSTANCE_MISUSE_MAX_CODE] not in ('66214007',
					'191882002',
					'191883007',
					'191884001',
					'191891003',
					'191893000',
					'191894006',
					'191895007',
					'191899001',
					'191905001',
					'191906000',
					'191909007',
					'191912005',
					'191913000',
					'191916008',
					'191918009',
					'191919001',
					'191920007',
					'191924003',
					'191925002',
					'191931004',
					'191934007',
					'191937000',
					'268645007',
					'268646008',
					'268647004',
					'268648009',
					'414874007')
				and [PSYCHOACTIVE_SUBSTANCE_MISUSE_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Psychoactive_substance_misuse]

			--Alcohol
			,case when ([ALCOHOL_ADVICE_MAX_CODE] is not null 
				and [ALCOHOL_ADVICE_MAX_CODE] in (
				--Liverpool codes
				'183486001','64297001','471691000000107','413130000','24165007' 
				--my extra codes
				,'171057006','135827004','390857005','166251000000100'
				--and root codes for 9k1%
				,'413475007','527961000000108','366421000000103','166471000000105','14251000000103','361731000000101','285381000000108','285991000000109','285411000000105','285441000000106','413897002','366371000000105','413473000') --+ a long list
				and [ALCOHOL_ADVICE_MAX] >= CONVERT(DATETIME, DATEADD(yyyy, -2, getdate()), 102)) then 1 else 0 end as [Alcohol_misuse]
				,'                     ' as Segment
into Client_SystemP_RW.RP103_Segmentation
from Client_SystemP_RW.RP102_Conditions

