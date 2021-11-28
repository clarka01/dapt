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
downtime_lease <- read_csv("LOCAL_REPOSITORY_LOCATION/DAPT/costar/distributions/downtime_lease_nov22.csv")


#Drop the first column
downtime_lease <- subset (downtime_lease, select = -X1)


days <- lease_data %>%
  dplyr::filter(days_on_market > 0)
fitw <- fitdist(days$days_on_market, "weibull")
fitlnorm <- fitdist(days$days_on_market, "lnorm")
#fitgamma <- fitdist(days$days_on_market, "gamma")
denscomp(list(fitw, fitlnorm))
summary(fitw)
summary(fitlnorm)
denscomp(days, fitw)