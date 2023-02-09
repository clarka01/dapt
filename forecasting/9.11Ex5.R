library(fpp3)
view(aus_retail)

#For your retail data (from Exercise 8 in Section 2.10), 
#find the appropriate order of differencing 
#(after transformation if necessary) to obtain stationary data.


set.seed(12345678)
myseries <- aus_retail %>%
  filter(`Series ID` == sample(aus_retail$`Series ID`, 1))
myseries %>% autoplot(Turnover)

#the variation is proportional to the level of the series. 
myseries %>% autoplot(log(Turnover))

# seasonal differencing?
myseries %>%
  features(log(Turnover), unitroot_nsdiffs)


myseries %>% autoplot(log(Turnover) %>% difference(lag = 12))

myseries <-  myseries %>%
  mutate(diff12_log_Turnover = difference(log(Turnover), 12))

# regular dufferencing?
myseries %>%  
  features(diff12_log_Turnover, unitroot_ndiffs)

myseries %>%  
features(diff12_log_Turnover, unitroot_kpss)

