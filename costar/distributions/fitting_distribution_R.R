library(tidyverse)
library(DBI)
library(odbc)
library(dplyr)
library(dbplyr)
library(RPostgres)
library(glmnet)
library(fitdistrplus)

library(pander)
library(ggthemes)
library(purrr)
library(ggsci)
library(ggplot2)
library(readr)
# library(forecast)
library(fable)

options(scipen = 1000)

# # connect to the database
# con <- DBI::dbConnect(RPostgres::Postgres(), 
#                       host = 'lease-data.cnzawwknyviz.us-east-1.rds.amazonaws.com',
#                       user = 'costar',
#                       password = rstudioapi::askForPassword('Costar12'))
# 
# downtime <- as_tibble(dbGetQuery(con,'SELECT * FROM downtime_lease_nov8'))

# set pander table-layout options --------
panderOptions('table.alignment.default', function(df)
  ifelse(sapply(df, is.numeric), 'right', 'left'))
panderOptions('table.split.table', Inf)

# import the file
lease_data <- read_csv("LOCAL_REPOSITORY_LOCATION/DAPT/costar/distributions/downtime_lease_nov22.csv")




lease <- lease_data %>%
  dplyr::filter(vacant_months > 0 & year_off_market >= 2008 & year_off_market <= 2020)

fitw <- fitdist(lease$vacant_months, "weibull")
fitlnorm <- fitdist(lease$vacant_months, "lnorm")
fitg <- fitdist(lease$vacant_months, "gamma")

denscomp(list(fitw, fitlnorm, fitg), xlab = 'vacant_months', ylab = 'Lease Count Density')
summary(fitw)
summary(fitlnorm)
summary(fitg)




lease_11244 <- lease %>%
  dplyr::filter(cbsaid == 11244) 

w <- fitdist(lease_11244$vacant_months, "weibull")
lnorm <- fitdist(lease_11244$vacant_months, "lnorm")
g <- fitdist(lease_11244$vacant_months, "gamma")
b <- fitdist(lease_11244$vacant_months, "beta")

denscomp(list(w, lnorm, g, b), xlab = 'vacant_months', ylab = 'Lease Count Density')
summary(w)
summary(lnorm)
summary(g)
summary(b)








