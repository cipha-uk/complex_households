#-----------------------------------------------------------------------------
# this script prepares the household cohort to analyse complex households
# for this work we are interested in households with children living in
# children are people aged up to 16 y.o.
# households are a set of people who have the same puprn 
# where the number of people is fewer than 10 (to exclude people living at multiple occupancy residences)
# a household is defined as having a complex need considering the cumulative characteristics and activity
# in a given period of 12 months - in this example the calendar year 2021
# a household has the most complex needs referring to the population of the same local authority
# thus, the computation of a 'complexity score' was divided into 9 C&M local authorities
# these are: Cheshire East, Cheshire West and Chester, Halton, Warrington in Cheshire
# Knowsley, Liverpool, Sefton, St. Helens, Wirral in Merseyside


#------------------------------------------------------------------------------
# author: Ben Barr, Roberta Piroddi
# date: 2022, 11
#------------------------------------------------------------------------------

library(data.table)
library(sf) 
library(dplyr)
library(ggplot2)
library(janitor)
library(readxl)


#-----------------------------------
# these are the 9 local authorities

#place<-"Liverpool"
#laname="Liverpool"

#place<-"CheshireEast"
#laname <-"Cheshire East"

#place <-"CheshireWest"
#laname <-"Cheshire West and Chester"

#place <-"StHelens"
#laname <-"St. Helens"

# place <-"Wirral"
# laname <-"Wirral"

# place <-"Warrington"
# laname <-"Warrington"

# place <-"Halton"
# laname <-"Halton"

# 
# place <-"Sefton"
# laname <-"Sefton"

#place <-"Knowsley"
#laname <-"Knowsley"


#--------------------------------------------------------------------------
# load input data
# this is the file with one row per person and with data of
# demographic characteristics
# residence - mainly pseudo uprn
# mortality
# conditions (mainly these are health conditions, but there may be also other characteristics, e.g. homelessness, being an informal carer)
# prescriptions for certain categories of medications in 12 months
# usage of services in 12 months

#----------------------------------------------------------------
# the script is repeated for each one of the 9 local authorities
# giving a value to the variable place and laname as above
# place_cldat_year.csv
# place is one of the 9 local authorities
# the files are yearly - so they will contain an indication of a year: for this case was 2021

d<- fread(paste0("../../path/to/directory",place,"_cldat_2021.csv"))

d<-clean_names(d)

setnames(d,names(d),tolower(names(d)))


# clean data:

# residence 
# limit data to Liverpool LSOAs
lk_lsoa_msoa_la<- fread("./path/to/data/lk_lsoa_msoa_la.csv")
d<-d[lsoa %in% lk_lsoa_msoa_la[ladnm==laname]$lsoa11] # we consider only people who are resident in lsoas in local authorities of C&M

#ethnicity
table(d$ethnic_group)
d[, ethnic_group:=tolower(ethnic_group)]
d[ethnic_group=="not stated", ethnic_group:=NA]
d[ethnic_group=="not stated", ethnic_group:=NA]
d[ethnic_group=="not known", ethnic_group:=NA]
d[ethnic_group=="1", ethnic_group:=NA]
d[ethnic_group=="", ethnic_group:=NA]
d[ethnic_group=="null", ethnic_group:=NA]   # all various unknown ethnic classification into 1 group of NA
d[, ethn:=recode(ethnic_group, "black or black british"="black", 
                    "asian or asian british"="asian",
                    "other ethnic groups"="other"
                  )]                              # re-coded so that there are only 5 categories: asian, black, mixed, other, and white
prop.table(table(d$ethn, useNA = "ifany")) #this is to check 


# date of death re-format if exists
d[, dod:=as.IDate(substr(date_of_death, 0,10),format = "%Y-%m-%d")]

# age for the year taken into consideration
d[, age:=as.numeric(2021-year_of_birth)]
d<-d[age>-1,]
#--remove NULLs & deceased individuals
d<-d[is.na(dod)==T ]
d<-d[deceased!="Y"]
d<-d[is.na(p_uprn)==F]
d<-d[p_uprn!="NULL"]
d<-d[p_uprn!=""]
d<-d[property_type!="NULL"]


#----------------------------------
# count the N: number of people and the people who are registered with gps who do not have a data sharing agreement and
# therefore need to be excluded
num_people_tot_2021 <- nrow(d)

num_people_dsa_2021 <- nrow(d[dsa_in_place==1,])

perc_gp <- as.character(round(num_people_dsa_2021/num_people_tot_2021*10000)/100)

gp_place <- data.table(place = c(laname),
                       pop_dsa = c(num_people_dsa_2021),
                       pop_gp = c(num_people_tot_2021),
                       perc_analysed = c(perc_gp))

save(gp_place, file=paste0("./path/to/Data/", place,"_gp_pop_numbers.Rdata")) #save these numbers for the slides

#------------------------------------------------------------
# exclude gps not having data sharing agreements (dsa)
d<-d[dsa_in_place==1,] #only analyse the ones that have agreed dsa


#age groups
d[, age_group:=cut(age, breaks=c(0,17,46,110), include.lowest=T, right=F)]
d[, agegroup1 := cut(age, breaks=c(0,10,17,26,46,66,110))]

#table(d$age, useNA = "ifany")
#table(d$sex, useNA = "ifany")
# drop those missing sex (n=13)
d<-d[sex=="M"|sex=="F"]


# make sure that in the input data file if people do not have contacts the value is set to 0 and not NA
# e.g contacts with a service- either someone has a record of contact or they dont - there can be no NA. 

#------------------------------------------
# number of long term conditions (ltc)
# the ltc considered are below, some are broad categoried e.g.rheumatological
# the value of each variable is 1/0 if a person has one condition in the category
# ckd - chronic kidney disease
# cld - chronic liver disease
# cvd - cardio-vascular disease
# cmhp - common mental health problem
# copd - chronic obstructive pulmonary disease
# smi - severe mental illness

d[,num_ltc:= cancer + asthma + ckd + cld + copd + cvd + cmhp + rheumatological+
            + dementia + diabetes + epilepsy + neurological
            + smi]

# here a distinction between physical long term health conditions
d[,num_phys_ltc:= cancer + asthma + ckd + cld + copd + cvd + rheumatological+
   diabetes + epilepsy + neurological+dementia]
# and mental long term conditions
d[,num_mental_ltc:= cmhp
  + smi]

#---------------------------------------------------------------------------------------------------
# note: make sure all labels for conditions and counts of service use and costs are numerical values


# costs -----------------------------------------

# check that the activity and presence of a conditions are numeric and not NA, replace all NAs with zero 
#d[is.na(d)] <- 0
numeric_cols <- names(which(sapply(d,is.numeric)))

d[,(numeric_cols):=lapply(.SD, function(x) replace(x, is.na(x), 0)), .SDcols = numeric_cols]

# for long term conditions - estimating primary care costs (from Symphony project )
d[,cost_ltc:= cancer*478 + asthma*312+ ckd*745 + copd*687 + cvd*644 + cmhp*372 + rheumatological*593+
    + dementia*757 + diabetes*604 + epilepsy*358 + neurological*644
  + smi*315]

# A&E
d[, cost_ae:=as.numeric(aae_attendances_cost_12)]
d[, high_ae:=as.numeric(aae1a2_attend_12>5)]


#admissions
d[, elective_admissions_cost_12:=as.numeric(elective_admissions_cost_12)]
d[, emergency_admissions_cost_12:=as.numeric(emergency_admissions_cost_12)]

# cost of all admissions 
d[,cost_ad:=emergency_admissions_cost_12+elective_admissions_cost_12]

# children looked after
table(d$child_looked_after_flag)
d[,child_looked_after_flag21:=child_looked_after_flag]
d[age>17, child_looked_after_flag21:=0 ]   # I am counting only people who are/were looked after and are children in the year considered
table(d$child_looked_after_flag21)
est_cla_cost <- 73263000/1490 # this is a value derived from the data published by Liverpool City Council

d[, cost_cla:=child_looked_after_flag21*est_cla_cost]

# social care
#exclude those living in care home
d<-d[nursing_care_home_flag=="" | nursing_care_home_flag=="NULL" | nursing_care_home_flag=="N",]

table(d$asc_cost_12,d$asc_services_12,useNA = "ifany") 

#------------------------------------------------------------------
# adult social care services from la statutory financial returns

d[,asc_start_date:=as.IDate(as.character(asc_start_date),format="%Y-%m-%d")]
d[, asc_user:=as.numeric(asc_services_12>0 | asc_requests_12>0 | (!is.na(asc_start_date) & year(asc_start_date)<2022 & year(asc_start_date)>2014))]
d[, asc_request_reason_carer_12:=as.numeric(!is.na(asc_request_reason_carer_12) | !(asc_request_reason_carer_12=="NULL"))]

d[, carer_sc:=as.numeric(asc_request_reason_carer_12>0)]

d[, cost_asc:=asc_user*16535]


# some extremely high contact number ~ 1200 per year - truncate at max 1/day

#hist(d$cs_contacts_tot_12)
d[cs_contacts_tot_12>365, cs_contacts_tot_12:=365]
d[, cost_cs:=cs_contacts_tot_12*80]

d[, cs_children:=cs_cont_service_children_12+cs_cont_service_healthvisitormidwife_12]
d[, cs_allied_nurs:=cs_cont_service_alliedhp_12+cs_cont_service_nursing_12]


# mental health
# identify learning disability MHDS service users
#d[, ld_mhds_contacts:=service_learning_community_12+ service_autism_12+service_neurodevelopment_12+service_learning_forensic_12]
d[, ld_mhds_contacts:=
    cont_service_autism_12 +
    cont_service_neurodevelopment_12 +
    cont_service_learning_forensic_12 + 
    cont_service_learning_neurodevelop_12+
    ref_service_learning_neurodevelop_12+
    ref_service_autism_12 +
    ref_service_neurodevelopment_12 +
    ref_service_learning_forensic_12 +
    ref_reason_autism_12+
    ref_reason_neurodevelopmental_12]


d[ , ld_mhds_user:=as.numeric(ld_mhds_contacts>0) ]
table(d$ld_mhds_user)


# mental health contacts (excluding learning disability contacts)

d[, mental_mhds_contacts:=mh_contacts_tot_12 -
                          cont_service_autism_12 -
                          cont_service_learning_forensic_12 -
                          cont_service_learning_neurodevelop_12 -
                          cont_service_neurodevelopment_12]


d[mental_mhds_contacts<0,mental_mhds_contacts:= 0]
d[, mental_mhds_user:=as.numeric(mental_mhds_contacts>0)]

d[is.na(gp_antidepressant_rx_12)==T, gp_antidepressant_rx_12:=0]
d[is.na(smi)==T, smi:=0]
d[is.na(alcohol_misuse)==T, alcohol_misuse:=0]
d[, substance_abuse:= fifelse(psychoactive_substance_misuse==1|
                              substance_or_alcohol==1|alcohol_misuse==1|
                              ref_reason_substance_12>0|ref_reason_substance_12>0 |
                              cont_service_substance_12>0|  aae_substance_12>0|
                              aae_alcohol_12>0| emadm_alcohol_12>0|emadm_substance_12
                                ,1,0)]


table(d$substance_abuse, useNA = "ifany")

d[ ,  smi_all:=fifelse(smi==1| 
                     ref_reason_psychosis_12>0|
                     ref_service_psychosis_early_12>0 |
                     ref_service_severe_12>0|
                   cont_service_psychosis_early_12>0 |
                     cont_service_severe_12>0, 1,0)
]

table(d$smi, useNA = "ifany")

d[, depression_all:=fifelse(depression==1| 
                              ref_reason_depression_12>0, 1,0)]

d[, anxiety_all:=fifelse(depression==1| 
                              ref_reason_anxiety_12>0, 1,0)]

#---------------------
# new variable for later

d[,cmhp_all:= as.numeric((depression_all+anxiety_all)>0)]

#---------------------------------------------------------------------------
#--------------------------------------
# contacts mh --- classify for later

     
d[, mhsds_neurodevelop_autism :=cont_service_learning_neurodevelop_12 + cont_service_learning_forensic_12+
    cont_service_neurodevelopment_12 + cont_service_autism_12 ]
d[, mhsds_complex_social :=  cont_service_roughsleeping_12 + 
    cont_service_substance_12 + cont_service_gambling_12 + cont_service_judicial_12 +             
    cont_service_lac_12 + cont_service_youth_offend_12 + cont_service_asylum_12]
d[, mhsds_crisis_eating :=  cont_service_crisis_12 + cont_service_liaison_12 + cont_service_eating_12 ]
d[, mhsds_cyp_specialist := cont_service_sp_access_12]
d[, mhsds_eating := cont_service_eating_12 ]
d[, mhsds_severe := cont_service_severe_12 + 
    cont_service_psychological_noniapt_12 + 
    cont_service_psychosis_early_12 + cont_service_gen_psychiatry_12 +
    cont_service_personality_12]
d[,mhsds_perinatal:= cont_service_perinatalparenting_12  ]
d[,mhsds_organic:=cont_service_community_org_12 ]
d[,mhsds_gp_community:=  cont_service_community_12 + cont_service_education_12 +
    cont_service_primary_care_12 ]
d[,mhsds_other:=cont_other_12 + cont_service_unknown_12]

d[,mhsds_severe_social:= mhsds_complex_social + mhsds_severe]




#--------------------------------
# reason for referral

d[, mh_reason_anxiety:= ref_reason_anxiety_12  ]

d[, mh_reason_depression := ref_reason_depression_12 + ref_reason_ocd_phobia_12]

d[,mh_reason_severe:= ref_reason_psychosis_12 + ref_reason_personality_12 ]

d[,mh_reason_substance:= ref_reason_substance_12]

d[,mh_reason_crisis:= ref_reason_crisis_12 + ref_reason_eating_12 + ref_reason_selfharm_12]

d[,mh_reason_perinatal:= ref_reason_perinatal_12 + ref_reason_attachment_12]

d[,mh_reason_autism := ref_reason_autism_12]

d[,mh_reason_neurodevelopment := ref_reason_neurodevelopmental_12]

d[,mh_reason_organic :=  ref_reason_organic_12]

d[,mh_reason_gender :=  ref_reason_gender_12]


d[,mh_reason_neurodevelopment_autism := ref_reason_neurodevelopmental_12 + ref_reason_autism_12]

d[,mh_reason_severe_substance:= ref_reason_psychosis_12 + ref_reason_personality_12 + ref_reason_substance_12 ]

d[, mh_reason_depression_plus := ref_reason_depression_12 + ref_reason_ocd_phobia_12 + ref_reason_gender_12]




#---------------------------------------------------------------------------
# get the definition of this study for a person with contact to mh services

d[, any_mh:=as.numeric(mental_mhds_contacts+
                         depression_all+
                         anxiety_all+
                         gp_antidepressant_rx_12+
                         smi_all+
                         substance_abuse+
                         emadm_selfharm_12+
                         emadm_eating_12+
                         emadm_substance_12+
                         emadm_alcohol_12 +
                         emadm_otherpsych_12+
                         aae_selfharm_12+
                         aae_alcohol_12+
                         aae_eating_12+
                         aae_substance_12
                         >0)]


prop.table(table(d$any_mh))


d[,ld_nd_autism:=fifelse(ld_mhds_user>0|learning_disability==1 | neurodevelopmental==1, 1, 0)]
table(d$ld_nd_autism)
#mental health emergency activity
d[, em_adm_mh:=emadm_selfharm_12+
    emadm_eating_12+
    emadm_substance_12+
    emadm_alcohol_12 +
    emadm_otherpsych_12]


d[, aae_mh:=
    aae_selfharm_12+
    aae_alcohol_12+
    aae_eating_12+
    aae_substance_12]

#costs mh contact
d[is.na(mh_contacts_tot_12)==T,mh_contacts_12:=0]
table(d$mh_contacts_tot_12)
# some exteme contact rate - limit to max of 1/day
d[mh_contacts_tot_12>365, mh_contacts_tot_12:=365, ]
d[mental_mhds_contacts>365, mental_mhds_contacts:=365, ]
#d[, cost_mh:=mental_mhds_contacts*216]
d[, cost_mh:=mh_contacts_tot_12*342]

# learning disabilities
table(d$ld_mhds_use,d$learning_disability, useNA = "ifany")
# update learning disability with mhds and asc data
d[ld_mhds_user>0, learning_disability:=1]
table(d$learning_disability, useNA = "ifany")
d[asc_request_reason_learning_12>0 | asc_service_reason_learning_12>0, learning_disability:=1]
# add the cost of learning disabilities now
d[, cost_ld:=learning_disability*3294]


#----------------------------------------------------
# list of variables to agreggate
# variables aggregate by p_uprn and age group
# variables are
# cost_ is the cost for different services
# num_ is the utilisation of services - num of contacts
# nump_ is the users, number of single people using the services

#this is a data frame for households and age groups
h_age <- d[is.na(age_group)==F, list
           (nump=.N,
             cost_ltc=sum(cost_ltc, na.rm = T),
             cost_ad=sum(cost_ad, na.rm = T), 
             cost_emad=sum(emergency_admissions_cost_12, na.rm = T),
             cost_ae=sum(cost_ae,na.rm = T),
             cost_mh=sum(cost_mh, na.rm = T), 
             cost_asc=sum(cost_asc, na.rm = T), 
             cost_cs=sum(cost_cs, na.rm = T),
             cost_ld=sum(cost_ld, na.rm = T),
             cost_cla=sum(cost_cla, na.rm = T),
             num_ltc=sum(num_ltc,na.rm = T),
             num_phys_ltc=sum(num_phys_ltc,na.rm = T),
             num_mental_ltc=sum(num_mental_ltc,na.rm = T),
             num_mh=sum(mental_mhds_contacts, na.rm = T),
             num_ld=sum(ld_mhds_contacts, na.rm = T),
             num_ae=sum(aae1a2_attend_12, na.rm = T),
             num_ad_el=sum(admissions_electives_12, na.rm = T),
             num_ad_em=sum(admissions_emergency_12, na.rm = T),
             num_em_adm_mh=sum(em_adm_mh, na.rm = T),
             num_aae_mh=sum(aae_mh, na.rm = T),
             num_cs=sum(cs_contacts_tot_12, na.rm = T),
             num_cs_exc_mwhv=sum(cs_contacts_tot_12-cs_cont_service_healthvisitormidwife_12, na.rm = T),
             num_cs_child=sum(cs_children, na.rm = T),
             num_cs_allied_nurs=sum(cs_allied_nurs, na.rm = T),
            nump_mh=sum(mental_mhds_user),
            nump_ld=sum(ld_mhds_user),
            nump_depanx=sum(as.numeric((gp_antidepressant_rx_12+depression_all+anxiety_all)>0)),
            nump_selfharm=sum(as.numeric((emadm_selfharm_12+aae_selfharm_12)>0)),
            nump_alc_drug=sum(as.numeric((alcohol_misuse+substance_abuse+emadm_substance_12+emadm_alcohol_12)>0)),
            nump_ae=sum(as.numeric(aae1a2_attend_12>0)),
            nump_high_ae=sum(high_ae),
            nump_ad_el=sum(as.numeric(admissions_electives_12>0)),
            nump_ad_em=sum(as.numeric(admissions_emergency_12>0)),
            nump_em_adm_mh=sum(as.numeric(em_adm_mh>0)),
            nump_aae_mh=sum(as.numeric(aae_mh>0)),
            nump_asc=sum(asc_user, na.rm = T),
            nump_cs=sum(as.numeric(cs_contacts_tot_12>0), na.rm = T),
            nump_cs_child=sum(as.numeric(cs_children>0), na.rm = T),
            nump_cs_allied_nurs=sum(as.numeric(cs_allied_nurs>0), na.rm = T),
            nump_cla=sum(child_looked_after_flag21, na.rm = T),
            nump_any_mh=sum(any_mh, na.rm = T),
            nump_care=sum(carer+carer_sc,na.rm = T), 
            nump_ltc=sum(as.numeric(num_ltc>0),na.rm = T),
             nump_phys_ltc=sum(as.numeric(num_phys_ltc>0),na.rm = T),
             nump_mental_ltc=sum(as.numeric(num_mental_ltc>0),na.rm = T),
            nump_lnds=sum(learning_disability,na.rm = T),
            nump_phds=sum(physical_disability,na.rm = T),
            nump_psych=sum(smi_all,na.rm = T),
            nump_complex=sum(complex,na.rm = T), 
            nump_homeless=sum(homeless,na.rm = T), 
            nump_alcohol_misuse=sum(alcohol_misuse, na.rm=T),
            nump_drug_misuse=sum(substance_abuse,na.rm = T)
           ), by=.(p_uprn, age_group)]

num<-ncol(h_age)
c<-names(h_age[, -c(1:2)])
# reshape the data.table to wide so that each age group has one of those variables singularly         
h_age<-dcast.data.table(h_age, p_uprn~age_group, value.var = c)

h_age[is.na(h_age)] <- 0
h_age<-clean_names(h_age)
# repeat the same for household and not age group
# all households
h <- d[is.na(age_group)==F, list
       (nump=.N,
         cost_ltc=sum(cost_ltc, na.rm = T),
         cost_ad=sum(cost_ad, na.rm = T), 
         cost_emad=sum(emergency_admissions_cost_12, na.rm = T),
         cost_ae=sum(cost_ae,na.rm = T),
         cost_mh=sum(cost_mh, na.rm = T), 
         cost_asc=sum(cost_asc, na.rm = T), 
         cost_cs=sum(cost_cs, na.rm = T),
         cost_ld=sum(cost_ld, na.rm = T),
         cost_cla=sum(cost_cla, na.rm = T),
         num_ltc=sum(num_ltc,na.rm = T),
         num_phys_ltc=sum(num_phys_ltc,na.rm = T),
         num_mental_ltc=sum(num_mental_ltc,na.rm = T),
         num_mh=sum(mental_mhds_contacts, na.rm = T),
         num_ld=sum(ld_mhds_contacts, na.rm = T),
         num_ae=sum(aae1a2_attend_12, na.rm = T),
         num_ad_el=sum(admissions_electives_12, na.rm = T),
         num_ad_em=sum(admissions_emergency_12, na.rm = T),
         num_em_adm_mh=sum(em_adm_mh, na.rm = T),
         num_aae_mh=sum(aae_mh, na.rm = T),
         num_cs=sum(cs_contacts_tot_12, na.rm = T),
         num_cs_exc_mwhv=sum(cs_contacts_tot_12-cs_cont_service_healthvisitormidwife_12, na.rm = T),
         num_cs_child=sum(cs_children, na.rm = T),
         num_cs_allied_nurs=sum(cs_allied_nurs, na.rm = T),
         nump_mh=sum(mental_mhds_user),
         nump_ld=sum(ld_mhds_user),
         nump_depanx=sum(as.numeric((gp_antidepressant_rx_12+depression_all+anxiety_all)>0)),
         nump_selfharm=sum(as.numeric((emadm_selfharm_12+aae_selfharm_12)>0)),
         nump_alc_drug=sum(as.numeric((alcohol_misuse+substance_abuse+emadm_substance_12)>0)),
         nump_ae=sum(as.numeric((aae1a2_attend_12)>0)),
         nump_high_ae=sum(high_ae),
         nump_ad_el=sum(as.numeric(admissions_electives_12>0)),
         nump_ad_em=sum(as.numeric(admissions_emergency_12>0)),
         nump_em_adm_mh=sum(as.numeric(em_adm_mh>0)),
         nump_aae_mh=sum(as.numeric(aae_mh>0)),
         nump_asc=sum(asc_user, na.rm = T),
         nump_cs=sum(as.numeric(cs_contacts_tot_12>0), na.rm = T),
         nump_cs_child=sum(as.numeric(cs_children>0), na.rm = T),
         nump_cs_allied_nurs=sum(as.numeric(cs_allied_nurs>0), na.rm = T),
         nump_cla=sum(child_looked_after_flag21, na.rm = T),
         nump_any_mh=sum(any_mh, na.rm = T),
         nump_care=sum(carer+carer_sc,na.rm = T), 
         nump_ltc=sum(as.numeric(num_ltc>0),na.rm = T),
         nump_phys_ltc=sum(as.numeric(num_phys_ltc>0),na.rm = T),
         nump_mental_ltc=sum(as.numeric(num_mental_ltc>0),na.rm = T),
         nump_lnds=sum(learning_disability,na.rm = T),
         nump_phds=sum(physical_disability,na.rm = T),
         nump_psych=sum(smi,na.rm = T),
         nump_complex=sum(complex,na.rm = T), 
         nump_homeless=sum(homeless,na.rm = T), 
         nump_alcohol_misuse=sum(alcohol_misuse, na.rm=T),
         nump_drug_misuse=sum(substance_abuse,na.rm = T)
       ), by=.(p_uprn)]
length(unique(d$p_uprn))

h<-merge(h, h_age, by="p_uprn")


# problem in data of multiple lsoa codes for UPRNs 
# make uprn to lsoa11 look up
# limit data to C&M LSOAs

uprn_lsoa_lk<-unique(d[, .(p_uprn,lsoa)])
uprn_lsoa_lk[, num_dupl:=.N, by=.(p_uprn)]
uprn_lsoa_lk[, seq_dupl:=1:.N, by=.(p_uprn)]

#replace the lsoa code of multiples with the first lsoa code for that UPRN
uprn_lsoa_lk[, lsoa:=lsoa[seq_dupl==1], by=.(p_uprn)]
uprn_lsoa_lk<-clean_names(unique(uprn_lsoa_lk[, .(lsoa,p_uprn)]))

h<-merge(h,uprn_lsoa_lk, by="p_uprn")

# limit to households with less than 10 at address. 
h<-h[nump<10]


# add IMD 2019
imd_dt <-  as.data.table(readxl::read_xlsx(".path/to/Data/imd2019_Scores.xlsx", sheet=2))
colnames(imd_dt)[1] <- 'lsoa11'
imd_dt<-clean_names(imd_dt)
imd_dt <- imd_dt[ ,.(lsoa=lsoa11,imd=index_of_multiple_deprivation_imd_score, inc_child_score=income_deprivation_affecting_children_index_idaci_score_rate,house_score=barriers_to_housing_and_services_score, inc_score=income_score_rate)]

h<-merge(h, imd_dt, by="lsoa", all.x = T)

# derived variables
# this is the total cost
# and the number of service types used
h[, total_cost:=cost_ltc+cost_ad+cost_ae+cost_mh+cost_ld + cost_asc+cost_cs+cost_cla]
h[, num_serv:=as.numeric((nump_ad_el+nump_ad_em)>0)+
    as.numeric((nump_ltc)>0) +
    as.numeric(num_mh >0)+
    as.numeric(num_cs>0)+
    as.numeric(num_ae>0)+
    as.numeric(nump_asc>0)+
    as.numeric(nump_cla>0)]


# these are the number of "problems" - prob stands for problem
h[, child_prob:=as.numeric(num_ltc_0_17 + num_mh_0_17+num_em_adm_mh_0_17+ num_aae_mh_0_17+nump_ld_0_17+nump_complex_0_17+nump_any_mh_0_17+num_cs_exc_mwhv_0_17+nump_cla>0)]

h[, parent_prob:=as.numeric(num_ltc_17_46 +num_mh_17_46+num_cs_17_46+num_ad_el_17_46+num_ae_17_46+ num_ad_em_17_46+nump_lnds_17_46+nump_complex_17_46+num_cs_exc_mwhv_17_46>0)]

h[, older_prob:=as.numeric(num_ltc_46_110 +num_mh_46_110+num_cs_46_110+num_ad_el_46_110+num_ae_46_110+ num_ad_em_46_110+nump_lnds_46_110+nump_complex_46_110+num_cs_exc_mwhv_46_110>0)]

h[, adult_prob:=as.numeric(parent_prob==1|older_prob==1)]

h[, parent_child_prob:= as.numeric(parent_prob+child_prob>1)]

h[, em_spend:=cost_emad+cost_ae] #
h[,el_spend:=cost_ad - cost_emad] # this is secondary elective cost
h[, elect_spend:=total_cost-em_spend] #elective spend
h[, soc_spend:=cost_asc+cost_ld+cost_cla] # social services and learning disability?
h[, cost_ph:=total_cost/nump] # cost per head - total cost/number of people
h[, hhid:=as.numeric(as.factor(p_uprn))]

#

#--complex households with children = hc---#
#limit to households with children
hc<-h[nump_0_17>0]


hc[, inc_ch_quint:=ntile(inc_child_score, 5)]
hc[, dep:=as.numeric(inc_ch_quint==5)] # deprived = lives in the most deprived quintile

hc[, lone_parent:=as.numeric(nump_17_46+nump_46_110==1)]

hc[, social:=nump_alcohol_misuse+nump_high_ae+nump_drug_misuse+nump_homeless+lone_parent+as.numeric(nump_complex_17_46>0)]


hc[, soc_fact:=factor(as.numeric(social>0), labels=c("No social problems", "social problems"))]

# quartiles of complexity and service expenditure 
hc[, pc_cost:=ntile(cost_ph, 4)]
table(hc$pc_cost)


#this is the current definition
hc[, complex_hh:=as.numeric((child_prob==1) & 
               (as.numeric(nump_phys_ltc>0) + as.numeric(nump_any_mh>0)==2) &
                            (num_serv>2 | social>0 |nump_cla>0) & 
                            pc_cost==4)]


table(hc$complex_hh)


save(h, file=paste0("./path/to/Data/", place,"household_dataset.Rdata"))
# h is the data containing information at household level for each household in the local authority

save(hc, file=paste0("./path/to/Data/", place,"household_dataset_children.Rdata"))
# hc is the data containing information at household level - but only for those households with children

i_ch<-merge(d, hc[, .(complex_hh, total_cost,p_uprn)], by="p_uprn", all.x=T)
# dataset linked with the individual data for the analysis
# takes d which contains every individual in the local authority and links
# hc which has information  where complex_hh is a flag 


save(i_ch, file=paste0("./path/to/Data/", place,"indiv_household_dataset_children.Rdata"))









