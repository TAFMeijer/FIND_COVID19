# This file creates a single .RData file to load in app.R

library(dplyr)        ###Data Frame manipulation package
library(tidyverse)    ###Keeping things Tidy
library(lubridate)    ###Date manipulation

#######################
#Data Connection to public CSV
#######################

###Load data from public URL
FINDCov19TrackerURL <- 'https://raw.githubusercontent.com/finddx/FINDCov19TrackerData/master/processed/data_all.csv'

###Create DF
FINDCov19 <- read.csv(url(FINDCov19TrackerURL))

#######################
#Create reported Daily, Monthly, Quarterly data sets
#######################

###Take a subset of relevant columns from the FIND Cov19 tracker data as reported days data, filtered on only country level observations
ReportedDaily <- FINDCov19[FINDCov19$set == 'country', ] %>% select(name, unit, time, new_tests_orig, new_cases_orig, new_deaths_orig)

###Reformat time column as date
ReportedDaily$time <-as.Date(ReportedDaily$time, format = "%Y-%m-%d")

#######Create Reported Months data set
###We start with the reported days data set
ReportedMonthly <- ReportedDaily 

###Reformat date as YYYY-mm, i.e 2021-02
ReportedMonthly$month_year <- format(as.Date(ReportedMonthly$time), "%Y-%m")

###Drop the orginal time column
ReportedMonthly <- ReportedMonthly[-c(3)]

###Group by Country, ISO code and the new month-year column & replace NA with 0
ReportedMonthly <- ReportedMonthly %>% group_by(name, unit, month_year) %>% summarise(sum(new_tests_orig > 0)
                                                                                      ,sum(new_cases_orig >0)
                                                                                      ,sum(new_deaths_orig >0))
ReportedMonthly[is.na(ReportedMonthly)] <- 0

###Rename Column names
colnames(ReportedMonthly) <- c('Country','ISO3'
                          ,'Month','Monthly count of days tests reported'
                          ,'Monthly count of days cases reported'
                          ,'Monthly count of days deaths reported')


#######Create Reported Quarterly data set
###We start with the reported daily data set
ReportedQuarterly <- ReportedDaily 

###Reformat date as YYYY-qq, i.e 2021-04
ReportedQuarterly <- ReportedQuarterly %>% mutate(quarter_year = paste0(substring(year(time),1,4),"-0",quarter(time)))

###Drop the orginal time column
ReportedQuarterly <- ReportedQuarterly[-c(3)]

###Group by Country, ISO code and the new month-quarter column & replace NA with 0
ReportedQuarterly <- ReportedQuarterly %>% group_by(name, unit, quarter_year) %>% summarise(sum(new_tests_orig > 0)
                                                                                            ,sum(new_cases_orig >0)
                                                                                            ,sum(new_deaths_orig >0))
ReportedQuarterly[is.na(ReportedQuarterly)] <- 0

###Rename Column names
colnames(ReportedQuarterly) <- c('Country','ISO3'
                          ,'Quarter','Quarterly count of days tests reported'
                          ,'Quarterly count of days cases reported'
                          ,'Quarterly count of days deaths reported')


#######################
#Create Daily, Monthly, Quarterly Average per 1,000 pop data sets
#######################

###Take a subset of relevant columns from the FIND Cov19 tracker data as days data, filtered on only country level observations
MeanDaily <- FINDCov19[FINDCov19$set == 'country', ] %>% select(name, unit, time, cap_new_tests, cap_new_cases, cap_new_deaths)

###Reformat time column as date
MeanDaily$time <-as.Date(MeanDaily$time, format = "%Y-%m-%d")

#######Create Mean Monthly data set
###We start with the Mean days data set
MeanMonthly <- MeanDaily 

###Detemrine the last date of a complete month and cut the dataset off at the latest complete month
maxdate <- max(MeanMonthly$time)
lastmonth <- as.Date(cut(maxdate, "month"))-1
MeanMonthly <- MeanMonthly %>% filter(time <= lastmonth)

###Reformat date as YYYY-mm, i.e 2021-02 
MeanMonthly$month_year <- format(as.Date(MeanMonthly$time), "%Y-%m")

###Drop the orginal time column
MeanMonthly <- MeanMonthly[-c(3)]

###Group by Country, ISO code and the new month-year column 
###ignoring NAs in the sum and replace NA with 0 (when all observations are NA)
MeanMonthly <- MeanMonthly %>% group_by(name, unit, month_year) %>% summarise(sum(cap_new_tests, na.rm=TRUE)
                                                                              ,sum(cap_new_cases, na.rm=TRUE)
                                                                              ,sum(cap_new_deaths, na.rm=TRUE))
MeanMonthly[is.na(MeanMonthly)] <- 0

###Rename Column names
colnames(MeanMonthly) <- c('Country','ISO3'
                          ,'Month','Monthly tests per 1,000 population'
                          ,'Monthly cases per 1,000 population'
                          ,'Monthly deaths per 1,000 population')

#######Create Mean Quarters data set
###We start with the Mean days data set
MeanQuarterly <- MeanDaily 

###Detemrine the last date of a complete month and cut the dataset off at the latest complete month
lastquarter <- as.Date(cut(maxdate, "quarter"))-1
MeanQuarterly <- MeanQuarterly %>% filter(time <= lastquarter)

###Reformat date as YYYY-qq, i.e 2021-04
MeanQuarterly <- MeanQuarterly %>% mutate(quarter_year = paste0(substring(year(time),1,4),"-0",quarter(time)))

###Drop the orginal time column
MeanQuarterly <- MeanQuarterly[-c(3)]

###Group by Country, ISO code and the new month-year column 
###ignoring NAs in the sum and replace NA with 0 (when all observations are NA)
MeanQuarterly <- MeanQuarterly %>% group_by(name, unit, quarter_year) %>% summarise(sum(cap_new_tests, na.rm=TRUE)
                                                                                    ,sum(cap_new_cases, na.rm=TRUE)
                                                                                    ,sum(cap_new_deaths, na.rm=TRUE))
MeanQuarterly[is.na(MeanQuarterly)] <- 0

###Rename Column names
colnames(MeanQuarterly) <- c('Country','ISO3'
                            ,'Quarter','Quarterly tests per 1,000 population'
                            ,'Quarterly cases per 1,000 population'
                            ,'Quarterly deaths per 1,000 population')

save(ReportedMonthly,ReportedQuarterly,MeanMonthly,MeanQuarterly
     #, file = "C19RM/job application & admin/FIND Data Scientist/Assessment/FIND_COV_data_portal/load_all.RData")
     , file = "load_all.RData")

