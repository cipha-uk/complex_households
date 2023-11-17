#-------------------------------------------------------------
# this script calls the other two scripts in a loop
# repeating for each local authority
# the 2 steps are
# 1. to define and identify the complex households with children withing each local authority in CM
# 2. produce a report of their characteristics
# this script also gives the functionality of running
# the report for all the local authorities in Cheshire and Merseyside combined
# -------------------------------------------------------------
# author: Ben Barr, 
# date: 2022, 11
# -------------------------------------------------------------
# adapted: Roberta Piroddi,
# date: 2023,11
#---------------------------------------------------------------



place_list<-c("Liverpool","CheshireEast","CheshireWest","StHelens","Wirral",
              "Warrington","Halton","Sefton","Knowsley")

laname_list<-c("Liverpool","Cheshire East","Cheshire West and Chester","St. Helens","Wirral","Warrington","Halton","Sefton","Knowsley")


for (i in 1:length(place_list)) {
  place<-place_list[i]
  laname<-laname_list[i]
  source("./01_systemP_complexhouseholds_compile_cohort.R")
  source("./02_systemP_complexhouseholds_produce_report.R")
}




place_list<-c("Liverpool","CheshireEast","CheshireWest","StHelens","Wirral",
              "Warrington","Halton","Sefton","Knowsley")

laname_list<-c("Liverpool","Cheshire East","Cheshire West and Chester","St. Helens","Wirral","Warrington","Halton","Sefton","Knowsley")


for (i in 1:length(place_list)) {
  place<-place_list[i]
  laname<-laname_list[i]
  load(paste0("./Data/", place,"household_dataset_children.Rdata"))
  # dataset linked with the individual data for the analysis
  load(paste0("./Data/", place,"indiv_household_dataset_children.Rdata"))
  h<-paste0("new_i",i)
  assign(h,i_ch)
  h2<-paste0("new_h",i)
  assign(h2,hc)
}

i_ch<-NULL
hc<-NULL
l = mget(ls(pattern="new_i"))
i_ch<-rbindlist(l, use.names=TRUE, fill=TRUE)

l = mget(ls(pattern="new_h"))
hc<-rbindlist(l, use.names=TRUE, fill=TRUE)
rm(list=ls(pattern="new_i"))

rm(list=ls(pattern="new_h"))
l<-NULL

place<-"Cheshire and Merseyside"
laname <- "Cheshire and Merseyside"

source("02_systemP_complexhouseholds_produce_report.R")
# put here the version that applies
