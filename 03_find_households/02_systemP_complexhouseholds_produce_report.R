#-----------------------------------------------------------------------------
# this script prepares the report containing
# statistics and comparisons between characteristics of complex households and the rest of households
# for a single local authority [place indicated by wildcard *]
# these are exampled of plots/charts and analytical summaries 
# that can be produces with the complex household data 
# produced through script 01 "01_systemP_complexhouseholds_compile_cohort.R"
# it takes as input:
# 1. "*household_dataset_children.Rdata" - household level data for place/local authority
# 2. "*indiv_household_dataset_children.Rdata" - individual level data for place/local authority
# it generates
# summary statistics for complex households
# comparisons between complex households and other households in the same local authority
# stratification by age group, sex
# maps with geographical patterns at lsoa level
# examples of drill-downs in service use
# prevalence of single conditions
#
#
#------------------------------------------------------------------------------
# author: Ben Barr, Roberta Piroddi
# date: 2022, 11
#------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------------------
# This software is released under the GNU GENERAL PUBLIC license. See the LICENSE file for details.

# THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. 

# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH 
# THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# You acknowledge and agree that the use of this software is at your own risk, and the authors disclaim 
# any and all liability for any direct, indirect, incidental, consequential, or special damages or losses 
# that may result from the use or inability to use the software.
# -------------------------------------------------------------------------------------------------------------

library(officer)
library(data.table)
library(ggplot2)
library(janitor)
library(readxl)

library(ggthemes)
library(RColorBrewer)
library(colorspace)
library(forcats)
library(gridExtra)
library(biscale)
library(cowplot)
library(ggspatial)
library(jtools)
library(ggstance)
library(officer)
library(flextable)


#---------------------------------------------------------------
# if it needs to be run alone for a single local authority
# specify, e.g.
# place<-"Liverpool"
# laname <- "Liverpool"


load(paste0("./Data/", place,"household_dataset_children.Rdata"))
# this loads hc - household level data - for households with children only

load(paste0("./Data/", place,"indiv_household_dataset_children.Rdata"))
# this loads i_ch
# individual level data of households with children in local authority

imd_dt <-  as.data.table(readxl::read_xlsx("./path/to/Data/imd2019_Scores.xlsx", sheet=2))
colnames(imd_dt)[1] <- 'lsoa11'
imd_dt<-clean_names(imd_dt)
imd_dt <- imd_dt[ ,.(lsoa=lsoa11,imd=index_of_multiple_deprivation_imd_score, inc_child_score=income_deprivation_affecting_children_index_idaci_score_rate,house_score=barriers_to_housing_and_services_score, inc_score=income_score_rate, la_name=local_authority_district_name_2019)]


i_ch[, child:=age<17]

i_ch[,agegroup:=cut(age,breaks=c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,200),include.lowest=T,right = FALSE,dig.lab = 2)]

str(i_ch$agegroup)

levels(i_ch$agegroup)<-c("0-4", "5-9", "10-14","15-19","20-24","25-29","30-34",
                         "35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75+")

levels(i_ch$agegroup)

cfdat3<-merge(i_ch, hc[, .(p_uprn,num_ltc_17_46,num_ltc_46_110, nump_any_mh_17_46,nump_any_mh_46_110, lone_parent,nump_high_ae_17_46, nump_high_ae_46_110, nump_alc_drug_17_46,nump_alc_drug_46_110, nump, nump_17_46,nump_46_110, social, inc_score, inc_child_score)], by="p_uprn")
cfdat3 <- cfdat3[is.na(complex_hh)==F,]

# cfdat3 links together the individual and the household level data

# ...... start powerpoint .....................................

my_pres <- read_pptx() 
layout_summary(my_pres)
#  ...........................slide 1..............................
my_pres <- add_slide(my_pres, layout = "Blank", master = "Office Theme")


paragraph <- fpar(ftext(paste("Households with complex needs in ",laname, sep=" "),
                        fp_text(font.size = 24)))

free_loc <- ph_location(
  left = 2, top = 3.5)
my_pres <- ph_with(my_pres, paragraph, 
                   location = free_loc )

system_p_logo<-file.path("./Figures/system_p_logo.jpg")
my_pres <- ph_with(my_pres, value = external_img(system_p_logo, width = 2, height = 0.5), 
                   location = ph_location(left = 7, top = 0.5), 
                   use_loc_size = FALSE) 


#  .........................................slide 2...........................
my_pres <- add_slide(my_pres, layout = "Blank", master = "Office Theme")

definition<-file.path("./Figures/definition.jpg")
my_pres <- ph_with(my_pres, value = external_img(definition), 
                   location = ph_location_fullsize()) 


# ..............................slide 3...........

num_house<-nrow(hc)
num_complex_house<-nrow(hc[complex_hh==1])

perc_comp<-round(num_complex_house*100/num_house)
cost_house<-sum(hc$total_cost)

cost_complex_house<-sum(hc[complex_hh==1]$total_cost)

perc_cost<-round(cost_complex_house*100/cost_house)

cost_complex_house_r<-round(sum(hc[complex_hh==1]$total_cost)/1000000)

num_complex_house<-nrow(hc[complex_hh==1])

num_child<-nrow(i_ch[age<17])
num_child_ch<-nrow(i_ch[age<17 & complex_hh==1])
nump_complexhouseholds <- nrow(i_ch[complex_hh==1]) # total number of people living inn-complex households with children
text<-paste("In", 
            laname , 
            "there are",
            num_house, 
            "households with children, of which",
            num_complex_house,
            "have complex needs. These households with complex needs include",
            nump_complexhouseholds, "people. This",
            perc_comp,"% of families, account for", perc_cost, "% of health and social care costs for families with children.","That is ?", cost_complex_house_r,"million in total.", sep = " ")
text

my_pres <- add_slide(my_pres, layout = "Blank", master = "Office Theme")


paragraph <- fpar(ftext(text,
                        fp_text(font.size = 20, color = "deeppink4")))

free_loc <- ph_location(
  left = 2, top = 2.5,  width = 7, height = 4)

my_pres <- ph_with(my_pres, paragraph, 
                   location = free_loc )


# ..............................slide 4...........

# geography

# map of lsoas and complex households
hc[complex_hh==1, num_child_ch:=nump_0_17]

lsoa_ch<-hc[, list(num_ch=sum(complex_hh, na.rm = T), num_child_ch=sum(num_child_ch, na.rm = T), num_child=sum(nump_0_17), nump=sum(nump), total_cost=sum(total_cost)), by=.(lsoa, inc_child_score,inc_score)]

sp_lsoa <- st_read(normalizePath("./path/to/data/shp/Lower_Layer_Super_Output_Areas__December_2011__Boundaries_EW_BGC.shp"))
sp_lsoa <- sp_lsoa[sp_lsoa$LSOA11CD %in% lsoa_ch$lsoa, ]
lsoa_ch[, comp_ch_rate:=(num_child_ch)*100/num_child]
rate_lsoa <- merge(sp_lsoa,lsoa_ch, by.x="LSOA11CD", by.y="lsoa", all.x=T)

max(rate_lsoa$num_ch)
map1<-ggplot() +
  geom_sf(data = rate_lsoa,aes(fill = num_ch), lwd=0) +
  scale_fill_continuous_sequential(palette = "SunsetDark", name="%",alpha = 1, limits=c(0,max(rate_lsoa$num_ch)))+
  guides(fill = guide_legend(title = "")) +
  theme(legend.text=element_text(size=12))+
  theme_void()+
  ggtitle("Number of complex need households")

map1

ggsave(paste0("Figures/", place,"_complexhouseholds_map_numcomphouseholds.tiff"),plot=last_plot(), units = "in", width=6, height=7, device = "tiff", scale = 1, dpi = 300)


map2<-ggplot() +
  geom_sf(data = rate_lsoa,aes(fill = comp_ch_rate), lwd=0) +
  scale_fill_continuous_sequential(palette = "SunsetDark", name="%",alpha = 1, limits=c(0,max(rate_lsoa$comp_ch_rate)))+
  guides(fill = guide_legend(title = "")) +
  theme(legend.text=element_text(size=12))+
  theme_void()+
  ggtitle("% children (0-16 y.o.) in complex need households")

map2

ggsave(paste0("Figures/", place,"_complexhouseholds_map_numchildren.tiff"),plot=last_plot(), units = "in", width=6, height=7, device = "tiff", scale = 1, dpi = 300)


#----------------------------------------------------------
# prepare deprivation data and plot

dep<-merge(i_ch[, .(p_uprn, lsoa, complex_hh)], imd_dt, by="lsoa")
dep[is.na(complex_hh)==T, complex_hh:=0]
dep[, quintile:=ntile(imd, 5)]
dep<-dep[, list(pop=.N, prop=mean(complex_hh)*100), by=.(quintile)]
dep[ , annotation := paste(round(prop),"%")]

plot_dep <- 
  ggplot(dep, aes(x=as.factor(quintile), y= prop)) +
  geom_bar(stat='identity', fill="deeppink4", width = 0.5) +
  geom_text(aes(label = annotation), position = position_dodge(0.8), color = "white", vjust = 1.5) +
  scale_x_discrete(labels = c("1 - least deprived","2","3","4","5 - most deprived")) +
  theme_minimal() + labs(x= "deprivation quintile", y = "population (%)") +
  theme(axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12)) 

 plot_dep
 ggsave(paste0("Figures/", place,"_complexhouseholds_deprivation.tiff"),plot=plot_dep, units = "in", width=7, height=5, device = "tiff", scale = 1, dpi = 300)

#------------------------------------ 
 

#-------------------------------------------------------------
# add plots to presentation 
 
my_pres <- add_slide(my_pres, layout = "Blank", master = "Office Theme")


#  title
paragraph <- fpar(ftext("Geography and deprivation",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))
free_loc <- ph_location(
  left = 0.1, top = 0.1)

my_pres <- ph_with(my_pres, paragraph, 
                   location = free_loc )

my_pres <- ph_with(my_pres, value = map1, location = ph_location(
  left = 0.1, top = 1)) 

my_pres <- ph_with(my_pres, value = plot_dep, location = ph_location(
  left = 3, top = 4.5)) 

my_pres <- ph_with(my_pres, value = map2, location = ph_location(
  left = 5.5, top = 1)) 


#-------------------------Slide 5
# age and sex


cfdat3[, complexity := factor(complex_hh,labels = c("other household","complex household"))]

plot_agedens <- 
  ggplot(cfdat3, aes(age)) + 
  geom_density(aes(fill=complexity), alpha = 0.8)+
  scale_fill_manual(values = c("darkslategray4","deeppink4"), labels=c("other households", "complex households")) +
  scale_x_continuous(limits= c(0,100), breaks = seq(0,100,by=5)) +
  theme_minimal() + 
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), axis.text.x=element_text(angle=90)) +
  theme(legend.text=element_text(size=12), legend.position = "bottom")+facet_grid(.~sex)

plot_agedens

ggsave(paste0("Figures/", place,"_complexhouseholds_agedens.tiff"),plot=last_plot(), units = "in", width=16, height=6, device = "tiff", scale = 1, dpi = 300)

# ....... write slide

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Age and sex",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))
free_loc <- ph_location(
  left = 0.1, top = 0.1)

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_agedens, location = ph_location_type(type = "body")) 


print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#--------------------------------------------------
# basic structure of household - by household size

tab_numpeople<- hc[, list(num_house=.N), by=.(complex_hh,nump)]
tab_numpeople[, perc:=num_house*100/sum(num_house), by=.(complex_hh)]
tab_numpeople[ , annotation := paste(round(perc),"%")]
tab_numpeople[ , complexity :=factor(complex_hh, labels=c("other households","complex households"))]
# shouldn't really be single person households - so exclude them from this 
plot_numpeople <- ggplot(tab_numpeople[nump>1], aes(x=as.factor(nump), y= perc, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity),size=3, position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = c("2","3","4","5","6","7","8","9")) +
  theme_minimal() + labs(title="All ages",x= "number of people in household", y = "households (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12)) +theme(legend.position = "bottom", legend.title = element_blank())
plot_numpeople

ggsave(paste0("Figures/", place,"_complexhouseholds_numpeople_in_households.tiff"),plot=plot_numpeople, units = "in", width=15, height=5, device = "tiff", scale = 1, dpi = 300)

#---------------------------------
# have a look at the number of adults of working age 

tab_numpeople<-cfdat3[age>16 & age<65, list(nump=.N), by=.(complex_hh,p_uprn)]
tab_numpeople<-tab_numpeople[, list(num_house=.N), by=.(complex_hh,nump)]
tab_numpeople[, perc:=num_house*100/sum(num_house), by=.(complex_hh)]
tab_numpeople[ , annotation := paste(round(perc),"%")]
tab_numpeople[ , complexity :=factor(complex_hh, labels=c("other households","complex households"))]

plot_numworkingpeople <- ggplot(tab_numpeople[nump<7], aes(x=as.factor(nump), y= perc, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity),size=3, position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = c("1","2","3","4","5","6","7","8","9")) +
  theme_minimal() + labs(title="Working Age", x="number of working age people in household", y = "households (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12)) +theme(legend.position = "bottom", legend.title = element_blank())
plot_numworkingpeople


ggsave(paste0("Figures/", place,"_complexhouseholds_numworkingageadults_in_households.tiff"),plot=plot_numworkingpeople, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  ...................................................... slide 6 
#  household composition

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Number of people in households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_numpeople, location = ph_location_type(type = "body", position_right = F,use_loc_size=F, width=4.5, height=6))

my_pres <- ph_with(my_pres, value = plot_numworkingpeople, location = ph_location_type(type = "body", position_right = T,use_loc_size=F, width=4.5, height=6)) 

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))




#--------------------------------slide 7
# ethnicity - 


ethntable1 <- cfdat3[ethn!="", list(pop=.N), by=.(ethn, complex_hh)]
ethntable1[, perc:=pop*100/sum(pop), by=.(complex_hh)]

ethntable1[,annotation:= paste(ethn,"\n",round(perc),"%")]
ethntable1[, complex_hh:=factor(complex_hh, labels = c("Other households", "Complex households"))]

ethntable1[, perc_text:=paste0(round(perc), "%")]
ethntable2<-dcast(ethntable1, ethn~complex_hh, value.var = "perc_text")

mytable<-qflextable(ethntable2)

mytable <- set_header_labels(mytable,
                             ethn = "Ethnicity"
)

mytable

df1 <- ethntable1[complex_hh=="Complex households"]

df1[, ymax := cumsum(perc)]
df1[, ymin := c(0,head(ymax, n=-1)) ]
df1[, labelpos := (ymax - ymin)/2]

df1[, pos_x:=4.2]
df1[ethn=="white", pos_x:=3]
ethnplot1 <- ggplot(df1, aes(ymax=ymax, ymin=ymin, xmax=4, xmin = 3, fill=ethn)) +
  geom_rect(colour = "white") +
  geom_label( x=4.3, aes( y= ymin + labelpos, label=annotation), size = 4, nudge_x = 20, color="white") +
  scale_fill_discrete_sequential(palette = "SunsetDark") + theme_void() +
  coord_polar(theta = "y") +
  xlim(c(2,4))+theme(legend.position = "none")

ethnplot1


#need to add table here
ggsave(paste0("Figures/", place,"_complexhouseholds_ringethn1.tiff"), ethnplot1, units = "in", width=5, height=5, device = "tiff", scale = 1, dpi = 300)


# ....... write slide 7

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Ethnicity",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = mytable, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

my_pres <- ph_with(my_pres, value = ethnplot1, location = ph_location_type(type = "body", position_right = T,use_loc_size=F)) 

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#---------------------------------------------- slide 8
# about use of services: 2 aspects
# 1. share of cost for services
# 2. number of different services used


hc[, cost_child_sc:=cost_cla]
hc[, soc_spend:=cost_asc+cost_child_sc]


#-------------------------------------------
# this is for the costs shared between service types

cost_share<-hc[complex_hh==1, list(em_spend=sum(em_spend),el_spend=sum(el_spend),
                                   cost_cs=sum(cost_cs),
                                   cost_mh=sum(cost_mh+cost_ld),
                                   adult_soc=sum(cost_asc),
                                   cost_child_sc=sum(cost_child_sc),
                                   cost_ltc=sum(cost_ltc) )]

cost_share<-as.data.table(t(cost_share))
cost_share[, label:=1:.N]
cost_share[, label:=factor(label, labels = c("Emergency secondary health",
                                             "Elective secondary health",
                                             "Community services",
                                             "Mental health and learning disability",
                                             "Adult social care",
                                             "Children's social care",
                                             "Primary care"))]

total_spend<- sum(cost_share$V1)
cost_share[,perc:=V1/total_spend*100]
cost_share[,annotation:=paste(as.character(round(perc)),"%")]


bp<- ggplot(cost_share, aes(x="", y=perc, fill=label))+
  geom_bar(width = 1, stat = "identity")
sharespend_pie<-bp + coord_polar("y", start=0) + geom_col(color = "Black") +
  geom_text(aes(label=annotation), color="white", size=5,
            position = position_stack(vjust = 0.5)) 
sharespend_pie <- sharespend_pie +
  scale_fill_discrete_sequential(name= "Service type", palette = "SunsetDark") +
  theme_void()

sharespend_pie <- sharespend_pie + 
  theme(legend.title = element_text(size = 14), 
        legend.text = element_text(size = 12))

sharespend_pie

ggsave(paste0("Figures/", place,"_complexhouseholds_sharespend_household.tiff"),plot=sharespend_pie, units = "in", width=7, height=5, device = "tiff", scale = 1, dpi = 300)

# number of services
#---------------------------------
# service use


#number of services used
plot_numserv <- ggplot(hc[complex_hh==1], aes( x=num_serv, y = (..count..)/sum(..count..)))+
  geom_bar(width = 0.5, stat = "count", fill="deeppink4")+
  scale_x_continuous("Number of services used", breaks = c(1:7))+
  scale_y_continuous(labels = scales::percent, limits = c(0,0.6)) +
  theme_minimal()+ ylab("households")+xlab("") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12) )

plot_numserv

ggsave(paste0("Figures/", place,"_complexhouseholds_numservices_household.tiff"),plot=plot_numserv, units = "in", width=7, height=5, device = "tiff", scale = 1, dpi = 300)


# ....... write slide 8a

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Service use - share of spend on complex households by service type",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )


my_pres <- ph_with(my_pres, value = sharespend_pie, location = ph_location_type(type = "body", position_right = T,use_loc_size=F)) 

# ....... write slide 8-----------------------------------

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Service use - Number of services used by complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_numserv, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))


print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# SUMMARY USE OF SERVICES
#

# this is for a period of 12 months
# in this case it was calendar year 2021


# summary considers
# children and adults separately
# the percentage of people who had contacts
# AND
# the number of contacts



cfdat3[ , had_emergecy_admission:=fifelse(admissions_emergency_12>0,1,0)]
cfdat3[ , had_elective_admission:=fifelse(admissions_electives_12>0,1,0)]
cfdat3[ , had_aae_attendance:=fifelse(aae1a2_attend_12>0,1,0)]
cfdat3[ , had_mhsds_referral:=fifelse(mh_referrals_tot_12>0,1,0)]
cfdat3[ , had_mhsds_contact:=fifelse(mh_contacts_tot_12>0,1,0)]
cfdat3[ , had_cs_contact:=fifelse(cs_contacts_tot_12>0,1,0)]

cfdat3[, child:=as.numeric(age<17)]

use_summary<-cfdat3[,list(nump=.N,
                          nump_emadm = mean(had_emergecy_admission,na.rm=TRUE)*100,
                          num_emadm = mean(admissions_emergency_12,na.rm=TRUE)*100,
                          nump_eladm = mean(had_elective_admission,na.rm=TRUE)*100,
                          num_eladm = mean(admissions_electives_12,na.rm=TRUE)*100,
                          nump_aae = mean(had_aae_attendance,na.rm=TRUE)*100,
                          num_aae = mean(aae1a2_attend_12,na.rm=TRUE)*100,
                          nump_mhref = mean(had_mhsds_referral,na.rm=TRUE)*100,
                          num_mhref = mean(mh_referrals_tot_12,na.rm=TRUE)*100,
                          nump_mhcont = mean(had_mhsds_contact,na.rm=TRUE)*100,
                          num_mhcont = mean(mh_contacts_tot_12,na.rm=TRUE)*100,
                          nump_cscont = mean(had_cs_contact,na.rm=TRUE)*100,
                          num_cscont = mean(cs_contacts_tot_12,na.rm=TRUE)*100
), by=.(complex_hh,child)]


ad_p_em <- round(use_summary[complex_hh==1 & child==0]$nump_emadm)
ad_n_em <- round(use_summary[complex_hh==1 & child==0]$num_emadm)

ad_p_el <- round(use_summary[complex_hh==1 & child==0]$nump_eladm)
ad_n_el <- round(use_summary[complex_hh==1 & child==0]$num_eladm)

ad_p_ae <- round(use_summary[complex_hh==1 & child==0]$nump_aae)
ad_n_ae <- round(use_summary[complex_hh==1 & child==0]$num_aae)

ad_p_mr <- round(use_summary[complex_hh==1 & child==0]$nump_mhref)
ad_n_mr <- round(use_summary[complex_hh==1 & child==0]$num_mhref)

ad_p_mc <- round(use_summary[complex_hh==1 & child==0]$nump_mhcont)
ad_n_mc <- round(use_summary[complex_hh==1 & child==0]$num_mhcont)

ad_p_asc <-round(mean(cfdat3[complex_hh==1 & child==0]$asc_user, na.rm=TRUE)*100)

ch_p_em <- round(use_summary[complex_hh==1 & child==1]$nump_emadm)
ch_n_em <- round(use_summary[complex_hh==1 & child==1]$num_emadm)

ch_p_em <- round(use_summary[complex_hh==1 & child==1]$nump_emadm)
ch_n_em <- round(use_summary[complex_hh==1 & child==1]$num_emadm)

ch_p_el <- round(use_summary[complex_hh==1 & child==1]$nump_eladm)
ch_n_el <- round(use_summary[complex_hh==1 & child==1]$num_eladm)

ch_p_ae <- round(use_summary[complex_hh==1 & child==1]$nump_aae)
ch_n_ae <- round(use_summary[complex_hh==1 & child==1]$num_aae)

ch_p_mr <- round(use_summary[complex_hh==1 & child==1]$nump_mhref)
ch_n_mr <- round(use_summary[complex_hh==1 & child==1]$num_mhref)

ch_p_mc <- round(use_summary[complex_hh==1 & child==1]$nump_mhcont)
ch_n_mc <- round(use_summary[complex_hh==1 & child==1]$num_mhcont)

ch_p_cc <- round(use_summary[complex_hh==1 & child==1]$nump_cscont)
ch_n_cc <- round(use_summary[complex_hh==1 & child==1]$num_cscont)

#------------------------------ slide 9 ------------------------
# add slide with bullet points


my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")


#  title
paragraph <- fpar(ftext("Health and care services - annual use in 2021",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))
free_loc <- ph_location(
  left = 0.1, top = 0.1)


my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )



list_paragraph <- block_list(
  fpar(ftext("For every 100 adults on average:",fp_text(font.size = 16, color = "black"))),
  
  fpar(ftext(paste(ad_p_em,"had",ad_n_em,"emergency admissions",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ad_p_el,"had",ad_n_el,"elective admissions",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ad_p_ae,"had",ad_n_ae,"A&E attendances",sep=" "),fp_text(font.size = 16, color = "black"))),
  
  fpar(ftext(paste(ad_p_mr,"had",ad_n_mr,"referrals to mental health services",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ad_p_mc,"had",ad_n_mc,"contacts with mental health services",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ad_p_asc,"were adult social care users",sep=" "),fp_text(font.size = 16, color = "black"))),
  
  fpar(ftext("For every 100 children on average:",fp_text(font.size = 16, color = "black"))),
  
  fpar(ftext(paste(ch_p_em,"had",ch_n_em,"emergency admissions",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ch_p_el,"had",ch_n_el,"elective admissions",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ch_p_ae,"had",ch_n_ae,"A&E attendances",sep=" "),fp_text(font.size = 16, color = "black"))),
  
  fpar(ftext(paste(ch_p_mr,"had",ch_n_mr,"referrals to mental health services",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ch_p_mc,"had",ch_n_mc,"contacts with mental health services",sep=" "),fp_text(font.size = 16, color = "black"))),
  fpar(ftext(paste(ch_p_cc,"had",ch_n_cc,"contacts with community health services",sep=" "),fp_text(font.size = 16, color = "black")))
) #end block list



my_pres <- ph_with(my_pres, value = list_paragraph, 
                   location = ph_location_type(type = "body"),
                   level_list = c(1L, 2L, 2L, 2L, 2L, 2L, 2L,1L, 2L, 2L, 2L, 2L, 2L, 2L))



#--------------------------------------------------------------------------------
# the next sections are specific for mental health 
#-----------------------------------------------------slide 10
# mental health conditions
# depression
# anxiety
# smi - severe mental health conditions
# ld_nd_autism - neurodevelopmental and learning disabilities

# compares the prevalence of these conditions in adults and children
# in complex households compared to the rest of households with children


mh<-cfdat3[, list(depression=mean(depression_all, na.rm=T),
                  anxiety=mean(anxiety_all, na.rm=T), 
                  smi=mean(smi_all, na.rm=T), 
                  ld_nd_autism=mean(ld_nd_autism, na.rm=T)), by=.(child,complex_hh)
]


mh<-melt(mh, id.vars=c("child","complex_hh"))

mh[, value:=value*100]
mh[,annotation:= paste(round(value),"%")]
mh[ , complexity :=factor(complex_hh, labels=c("other households","complex households"))]

plot_cond_ch <- ggplot(mh[child==T], aes(x=variable, y= value, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  ylim(0,50)+
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity), position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = c("depression", "anxiety","severe \n mental \n illness","learning \n disability \n (incl. autism)")) +
  theme_minimal() + labs(title="Children", x= "condition", y = "prevalence (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12), legend.title = element_blank()) +
  theme(axis.text = element_text(size=10.5))+theme(legend.position = "bottom")

plot_cond_ch

ggsave(paste0("Figures/", place,"_complexhouseholds_mhldcond_child_in_households.tiff"),plot=plot_cond_ch, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


plot_cond_adult <- ggplot(mh[child==F], aes(x=variable, y= value, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  ylim(0,50)+
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity), position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = c("depression", "anxiety","severe \n mental \n illness","learning \n disability \n (incl. autism)")) +
  theme_minimal() + labs(title="Adults", x= "condition", y = "prevalence (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=11), legend.title = element_blank()) +
  theme(axis.text = element_text(size=10.5))+theme(legend.position = "bottom")

plot_cond_adult 

ggsave(paste0("Figures/", place,"_complexhouseholds_mhldcond_adult_in_households.tiff"),plot=plot_cond_adult, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


# ....... write slide 10

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Mental health conditions and learning disabilities",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

#my_pres <- ph_with(my_pres, value = plot_cond_adult, location = ph_location_type(type = "body", position_right = F,use_loc_size=T))
my_pres <- ph_with(my_pres, value = plot_cond_adult, location = ph_location_label(ph_label = "Content Placeholder 2") )

#my_pres <- ph_with(my_pres, value = plot_cond_ch, location = ph_location_type(type = "body", position_right = T,use_loc_size=T)) 
my_pres <- ph_with(my_pres, value = plot_cond_ch, location = ph_location_label(ph_label = "Content Placeholder 3") )

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#-------------------------------------------------------------------------- slide 11
# looking at mental health with more granular detail for people in complex households - any mental health problem
# any mental health problem was defined in script 01
# it means having a diagnosis of a mental health condition 
# OR having been prescribed antidepressants
# OR having had an attendance to A&E because of mental health reasons
# OR having an admission because of mental health reasons
# OR having a referral to or a contact with mental health services

table_anymh<-cfdat3[complex_hh==1, list(perc=mean(any_mh, na.rm=T)*100), by=.(agegroup,sex)]

plot_anymh <- ggplot(table_anymh, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_anymh <- plot_anymh + geom_bar(stat='identity',position="dodge")

plot_anymh <- plot_anymh + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_anymh <- plot_anymh + theme_minimal() + labs(title = "People with any mental health problem", x= "age group", y = "population (%)")

plot_anymh 

ggsave(paste0("Figures/", place,"_complexhouseholds_anymh.tiff"),plot_anymh, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 11

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Age and gender of people with mental health problems in complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_anymh, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))


print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

#-------------------------------------slide 12
# common mental health problems (anxiety and depression) prevalence in complex households
# depression

table_depression<-cfdat3[complex_hh==1, list(perc=mean(depression_all, na.rm=T)*100), by=.(agegroup,sex)]

plot_depression <- ggplot(table_depression, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_depression <- plot_depression + geom_bar(stat='identity',position="dodge")

plot_depression <- plot_depression + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_depression <- plot_depression + theme_minimal() +
  labs(title = "People with depression", x= "age group", y = "population (%)")+
  theme(legend.position = "bottom", axis.text.x = element_text(angle=90), legend.title = element_blank())

plot_depression 

ggsave(paste0("Figures/", place,"_complexhouseholds_depression.tiff"),plot_depression, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)

#-------------------------------------------------------------------
# anxiety

table_anxiety<-cfdat3[complex_hh==1, list(perc=mean(anxiety_all, na.rm=T)*100), by=.(agegroup,sex)]

plot_anxiety <- ggplot(table_anxiety, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_anxiety <- plot_anxiety + geom_bar(stat='identity',position="dodge")

plot_anxiety <- plot_anxiety + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_anxiety <- plot_anxiety + theme_minimal() + labs(title = "People with anxiety", x= "age group", y = "population (%)")+
  theme(legend.position = "bottom", axis.text.x=element_text(angle=90), legend.title = element_blank())

plot_anxiety 

ggsave(paste0("Figures/", place,"_complexhouseholds_anxiety.tiff"),plot_anxiety, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 12

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Depression and anxiety in complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_depression, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

my_pres <- ph_with(my_pres, value = plot_anxiety, location = ph_location_type(type = "body", position_right = T,use_loc_size=T))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#--------------------slide 13
# severe mental health illness (smi) and substance abuse prevalence in complex households
# smi

table_smi<-cfdat3[complex_hh==1, list(perc=mean(smi_all, na.rm=T)*100), by=.(agegroup,sex)]

plot_smi <- ggplot(table_smi, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_smi <- plot_smi + geom_bar(stat='identity',position="dodge")

plot_smi <- plot_smi + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_smi <- plot_smi + theme_minimal() +
  labs(title = "People with severe mental illness", x= "age group", y = "population (%)")+
  theme(legend.position = "bottom", axis.text.x=element_text(angle=90), legend.title = element_blank())

plot_smi 

ggsave(paste0("Figures/", place,"_complexhouseholds_smi.tiff"),plot_smi, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)
# physical health


#--------------------------------------------------------
# substance_misuse

table_substance_misuse<-cfdat3[complex_hh==1, list(perc=mean(substance_abuse, na.rm=T)*100), by=.(agegroup,sex)]

plot_substance_misuse <- ggplot(table_substance_misuse, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_substance_misuse <- plot_substance_misuse + geom_bar(stat='identity',position="dodge")

plot_substance_misuse <- plot_substance_misuse + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_substance_misuse <- plot_substance_misuse + theme_minimal() + labs(title = "People with substance misuse (including alcohol)", x= "age group", y = "population (%)")+theme(legend.position = "bottom", axis.text.x=element_text(angle=90), legend.title = element_blank())

plot_substance_misuse 

ggsave(paste0("Figures/", place,"_complexhouseholds_substance_misuse.tiff"),plot_substance_misuse, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)

#  .......... write slide 13

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Severe mental illness and substance misuse complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_smi, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

my_pres <- ph_with(my_pres, value = plot_substance_misuse, location = ph_location_type(type = "body", position_right = T,use_loc_size=T))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

#------------------------------------------------------------------
# This next session is about uses of services for mental health reasons


#---------------------slide 14
# A&E attendances for mental health reasons
# mental health reasons are
# self harm
# eating disorders
# alcohol and drug abuse
# any other psychological problem
# the algorithm to define and extract these is in sql code

# A&E attendences

table_aae_mh<-cfdat3[complex_hh==1, list(perc=mean(aae_mh>0, na.rm=T)*100), by=.(agegroup,sex)]

plot_aae_mh <- ggplot(table_aae_mh, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_aae_mh <- plot_aae_mh + geom_bar(stat='identity',position="dodge")

plot_aae_mh <- plot_aae_mh + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_aae_mh <- plot_aae_mh + theme_minimal() + labs(title = "People attending A&E because of mental health problems", x= "age group", y = "population (%)")

plot_aae_mh 

ggsave(paste0("Figures/", place,"_complexhouseholds_aae_mh.tiff"),plot_aae_mh, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)

#  .......... write slide 14

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("A&E attendances for mental health problems",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_aae_mh, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))


print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

# ........................................slide 15 
# Emergency admissions for mental health reasons
# mental health reasons are
# self harm
# eating disorders
# alcohol and drug abuse
# any other psychological problem
# the algorithm to define and extract these is in sql code



# Emergency admissions
table_em_adm_mh<-cfdat3[complex_hh==1, list(perc=mean(em_adm_mh>0, na.rm=T)*100), by=.(agegroup,sex)]

plot_em_adm_mh <- ggplot(table_em_adm_mh, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_em_adm_mh <- plot_em_adm_mh + geom_bar(stat='identity',position="dodge")

plot_em_adm_mh <- plot_em_adm_mh + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_em_adm_mh <- plot_em_adm_mh + theme_minimal() + labs(title = "People with emergency admission for mental health reason", x= "age group", y = "population (%)")

plot_em_adm_mh 

ggsave(paste0("Figures/", place,"_complexhouseholds_em_adm_mh.tiff"),plot_em_adm_mh, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)

#  .......... write slide 15

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Emergency admissions for mental health problems",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_em_adm_mh, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

# ...............................slide 16
# Mental health contacts
# these are contacts with any of the teams for
# mental health services in the community (routine mental health)
# the algorithm to identify and extract them is in sql code


# Mental Health contacts

table_mh_contacts_tot_12<-cfdat3[complex_hh==1, list(perc=mean(mh_contacts_tot_12>0, na.rm=T)*100), by=.(agegroup,sex)]

plot_mh_contacts_tot_12 <- ggplot(table_mh_contacts_tot_12, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_mh_contacts_tot_12 <- plot_mh_contacts_tot_12 + geom_bar(stat='identity',position="dodge")

plot_mh_contacts_tot_12 <- plot_mh_contacts_tot_12 + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_mh_contacts_tot_12 <- plot_mh_contacts_tot_12 + theme_minimal() + labs(title = "People in contact with mental health services", x= "age group", y = "population (%)")

plot_mh_contacts_tot_12 

ggsave(paste0("Figures/", place,"_complexhouseholds_mh_contacts_tot_12.tiff"),plot_mh_contacts_tot_12, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 16

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Use of community mental health services for mental health problems",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_mh_contacts_tot_12, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

# .............................Slide 17 ............................
# which reasons for referral and which type of service

# it looks at the reasons for referrals to mental health services
# the way these are defined and grouped is
# in R code script 01


cols=c( "mh_reason_organic",
       "mh_reason_neurodevelopment_autism",
       "mh_reason_perinatal",
       "mh_reason_crisis",
       "mh_reason_anxiety",
       "mh_reason_depression_plus",
       "mh_reason_severe_substance")

mhr<-cfdat3[complex_hh==1,lapply(.SD, sum, na.rm=TRUE),
           .SDcols=cols]


mhr<-melt(mhr)
mhr[, perc:=value*100/sum(value)]
mhr[,annotation:= paste(round(perc),"%")]

mhr[, reason:=1:.N]
mhr[, reason:=factor(reason, labels = c( "Organic",
                                          "Neurodevelopmental and autism",
                                          "Perinatal",
                                          "Crisis, self-harm and eating disorder",
                                          "Anxiety",
                                          "Depression",
                                          "Severe mental illness and substance abuse"))]

pie_reasonsproper_mhsds<- ggplot(mhr, aes(x="", y=value, fill=reason))+
  #geom_bar(width = 1, stat = "identity")+
  coord_polar("y", start=0) + geom_col(color = "Black") +
  geom_text(aes(label=annotation), color="white", size=5,
            position = position_stack(vjust = 0.5)) +
  scale_fill_discrete_sequential(palette = "SunsetDark") +
  theme_void()

pie_reasonsproper_mhsds <- pie_reasonsproper_mhsds + 
  theme(legend.title = element_text(size = 14), 
        legend.text = element_text(size = 12))

pie_reasonsproper_mhsds

ggsave(paste0("Figures/", place,"_complexhouseholds_mhsds_reason_household.tiff"),plot=pie_reasonsproper_mhsds, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 17.............................................


my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Reasons for use community mental health services by complex households (% contacts)",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = pie_reasonsproper_mhsds, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#...................... slide 18.........................
# types of mental health service
# this looks at the type of service team people were referred to 
# the way these are defined and grouped is
# in R code script 01

cols=c("mhsds_neurodevelop_autism",
       "mhsds_perinatal",
       "mhsds_crisis_eating",
       "mhsds_gp_community",
       "mhsds_severe_social",
       "mhsds_cyp_specialist",
       "mhsds_other")

mh<-cfdat3[complex_hh==1,lapply(.SD, sum, na.rm=TRUE),
           .SDcols=cols]


mh<-melt(mh)
mh[, perc:=value*100/sum(value)]
mh[,annotation:= paste(round(perc),"%")]

mh[, service:=1:.N]
mh[, service:=factor(service, labels = c( "Learning disabilities",
                                          "Perinatal",
                                          "Crisis, self-harm and eating disorders",
                                          "Primary care and community",
                                          "Specialist severe illness and high need",
                                          "Specialist children and young people mental health",
                                          "Other"))]

pie_reasons_mhsds<- ggplot(mh, aes(x="", y=value, fill=service))+
  #geom_bar(width = 1, stat = "identity")+
  coord_polar("y", start=0) + geom_col(color = "Black") +
  geom_text(aes(label=annotation), color="white", size=5,
            position = position_stack(vjust = 0.5)) +
  scale_fill_discrete_sequential(palette = "SunsetDark") +
  theme_void()

pie_reasons_mhsds <- pie_reasons_mhsds + 
  theme(legend.title = element_text(size = 14), 
        legend.text = element_text(size = 12))

pie_reasons_mhsds

ggsave(paste0("Figures/", place,"_complexhouseholds_mhsds_servicetype_household.tiff"),plot=pie_reasons_mhsds, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 18.............................................

my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Types of community mental health servicesused by complex households (% of contacts)",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = pie_reasons_mhsds, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))

#-----------------------------------------------------------------------
# .................. slide 19...
# this is an example of an analysis for a subgroup of the population
# reasons of contacts with mental health services for young women
cols=c( "mh_reason_neurodevelopment_autism",
        "mh_reason_perinatal",
        "mh_reason_crisis",
        "mh_reason_anxiety",
        "mh_reason_depression_plus",
        "mh_reason_severe_substance")

mhyw<-cfdat3[age>14 & age<30 & sex=="F" & complex_hh==1,lapply(.SD, sum, na.rm=TRUE),
           .SDcols=cols]

mhyw<-melt(mhyw)


mhyw[, perc:=value*100/sum(value)]
mhyw[,annotation:= paste(round(perc),"%")]

mhyw[, reason:=1:.N]
mhyw[, reason:=factor(reason, labels = c( "Neurodevelopmental \n and \n autism",
                                         "Perinatal",
                                         "Crisis, \n self-harm \n and \n eating disorder",
                                         "Anxiety",
                                         "Depression",
                                         "Severe \n mental illness \n and \n substance abuse"))]

plot_mhsds_reasons_yw <- ggplot(mhyw, aes( x=fct_inorder(reason), y = perc))+
  geom_bar(width = 0.5, stat = "identity", fill="deeppink4")+
  theme_minimal()+ ylab("contacts for women aged 15-30 (%)")+xlab("reason for contact") +
  theme( axis.text.x=element_text(angle=0), axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12) )


plot_mhsds_reasons_yw

ggsave(paste0("Figures/", place,"_complexhouseholds_mhsds_reasons_youngwomen.tiff"),plot=plot_mhsds_reasons_yw, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


# map of where young women with mental health problems are

lsoa_ywmh<-cfdat3[sex=="F" & age>14 & age < 30, 
                  list(rate_mh=100*mean(any_mh,na.rm=T), num_mh=sum(any_mh, na.rm = T), numf=.N), 
                  by=.(lsoa)]
lsoa_ywmh[,rate_mh := num_mh/(numf+0.0001)*100]

rate_lsoa_mh <- merge(sp_lsoa,lsoa_ywmh, by.x="LSOA11CD", by.y="lsoa", all.x=T)

max_rate_yw<-max(rate_lsoa_mh$rate_mh)


map_yw_mh<-ggplot() +
  geom_sf(data = rate_lsoa_mh,aes(fill = num_mh), lwd=0) +
  scale_fill_continuous_sequential(palette = "SunsetDark", name="%",alpha = 1, limits=c(0,min(55,max_rate_yw)))+
  guides(fill = guide_legend(title = "")) +
  theme(legend.text=element_text(size=12))+
  theme_void()+
  ggtitle("% of young girls and women (15-30) with mental health problems")

map_yw_mh

ggsave(paste0("Figures/", place,"_complexhouseholds_map_ywmh_n.tiff"),plot=map_yw_mh, units = "in", width=10, height=7, device = "tiff", scale = 1, dpi = 300)

#  .......... write slide 19

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Mental health problems amongst 15-30 year-old women",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_mhsds_reasons_yw, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))

my_pres <- ph_with(my_pres, value = map_yw_mh, location = ph_location_type(type = "body", position_right = T,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


#---------------------------------------------------------------------------------------
# This next set of slides is for physical health conditions
# ................... slide 20
#  physical health
#  list of conditions flagged here

#-- adults
cols=c("diabetes",
       "cancer",
       "cvd",
       "asthma",
       "copd",
       "rheumatological",
       "ckd",
       "epilepsy",
       "neurological",
       "dementia")


mm_adults<-cfdat3[age>16, lapply(.SD, mean, na.rm=TRUE), .SDcols=cols, by=.(complex_hh)]

mm<-melt(mm_adults, id.vars=c("complex_hh"))

mm[, value:=value*100]
mm[,annotation:= paste(round(value),"%")]
mm[ , complexity :=factor(complex_hh, labels=c("other households","complex households"))]

plot_phycond_ad <- ggplot(mm, aes(x=variable, y= value, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity), position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = cols) +
  theme_minimal() + labs(title="Adults", x= "condition", y = "prevalence (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12)) +
  theme(axis.text = element_text(size=11), axis.text.x=element_text(angle=90))+theme(legend.position = "bottom")

plot_phycond_ad

ggsave(paste0("Figures/", place,"_complexhouseholds_phycond_adult_in_households.tiff"),plot=plot_phycond_ad, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)

#---------- children

cols=c("diabetes",
       "asthma",
       "rheumatological",
       "epilepsy")
mm_child<-cfdat3[age<17, lapply(.SD, mean, na.rm=TRUE), .SDcols=cols, by=.(complex_hh)]

mm<-melt(mm_child, id.vars=c("complex_hh"))

mm[, value:=value*100]
mm[,annotation:= paste(round(value),"%")]
mm[ , complexity :=factor(complex_hh, labels=c("other households","complex households"))]

plot_phycond_child <- ggplot(mm, aes(x=variable, y= value, fill=complexity)) +
  geom_bar(stat='identity',position="dodge") +
  scale_fill_manual(values = c("darkslategrey","deeppink4")) +
  geom_text(aes(label = annotation, colour=complexity), position = position_dodge(0.8), vjust = -0.5) +
  scale_colour_manual(values = c("darkslategrey","deeppink4")) +
  scale_x_discrete(labels = cols) +
  theme_minimal() + labs(title="Children", x= "condition", y = "prevalence (%)") +
  theme( axis.title.x  = element_text(size=12),axis.title.y= element_text(size=12), title= element_text(size=14)) +
  theme(legend.text=element_text(size=12)) +
  theme(axis.text = element_text(size=11), axis.text.x=element_text(angle=90))+theme(legend.position = "bottom")

plot_phycond_child

ggsave(paste0("Figures/", place,"_complexhouseholds_phycond_child_in_households.tiff"),plot=plot_phycond_child, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#  .......... write slide 20

my_pres <- add_slide(my_pres, layout = "Two Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Physical health problems in complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_phycond_ad, location = ph_location_type(type = "body", 
                                                                                         position_right = F,use_loc_size=F))

my_pres <- ph_with(my_pres, value = plot_phycond_child, location = ph_location_type(type = "body", 
                                                                                         position_right = T,use_loc_size=F))

print(my_pres, target = paste0("Figures/", place,"complex_households.pptx"))


# The following slides are examples of analysis dives in specific conditions of interest
#-------------------------------------- slide 21
# asthma

table_asthma<-cfdat3[complex_hh==1, list(perc=mean(asthma, na.rm=T)*100), by=.(agegroup,sex)]

plot_asthma <- ggplot(table_asthma, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_asthma <- plot_asthma + geom_bar(stat='identity',position="dodge")

plot_asthma <- plot_asthma + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_asthma <- plot_asthma + theme_minimal() + labs(title = "People with asthma", x= "age group", y = "population (%)")+theme(legend.position = "bottom", legend.title = element_blank())

plot_asthma

ggsave(paste0("Figures/", place,"_complexhouseholds_asthma.tiff"),plot_asthma, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)



#  .......... write slide 21
my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Asthma in complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_asthma, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))


#--------------------------------slide 22
# rheumatological


table_rheumatological<-cfdat3[complex_hh==1, list(perc=mean(rheumatological, na.rm=T)*100), by=.(agegroup,sex)]

plot_rheumatological <- ggplot(table_rheumatological, aes(x=agegroup, y= perc, fill=as.factor(sex)))

plot_rheumatological <- plot_rheumatological + geom_bar(stat='identity',position="dodge")

plot_rheumatological <- plot_rheumatological + scale_fill_manual("Sex", values = c("deeppink4","cadetblue4"))

plot_rheumatological <- plot_rheumatological + theme_minimal() + labs(title = "People with rheumatological conditions", x= "age group", y = "population (%)")+theme(legend.position = "bottom", legend.title = element_blank())

plot_rheumatological 

ggsave(paste0("Figures/", place,"_complexhouseholds_rheumatological.tiff"),plot_rheumatological, units = "in", width=10, height=5, device = "tiff", scale = 1, dpi = 300)


#....................... write slide 22
my_pres <- add_slide(my_pres, layout = "Title and Content", master = "Office Theme")

#  title
paragraph <- fpar(ftext("Rheumatological conditions in complex households",
                        fp_text(font.size = 20, color = "deeppink4", bold = T)))

my_pres <- ph_with(my_pres, paragraph, 
                   location = ph_location_type(type = "title") )

my_pres <- ph_with(my_pres, value = plot_rheumatological, location = ph_location_type(type = "body", position_right = F,use_loc_size=F))



