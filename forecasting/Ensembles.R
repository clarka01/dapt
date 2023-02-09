library(fpp3)
library(tsibble)
library(dplyr)


#Monthly revenue from take-away food in Australia, 
#from April 1982 to December 2018.

aus_takeaway <- aus_retail %>%
  filter(stringr::str_detect(Industry, "Takeaway"))%>%
  summarise(Turnover = sum(Turnover))

aus_takeaway %>% autoplot(Turnover)

train <- aus_takeaway %>%
  filter(year(Month) <= 2013)

STLF <- decomposition_model(
  STL(log(Turnover) ~ season(window = Inf)),
  ETS(season_adjust ~ season("N"))
)

takeaway_models <- train %>%
  model(
    ets = ETS(Turnover),
    stlets = STLF,
    arima = ARIMA(log(Turnover))
  ) %>%
  mutate(COMB_simple = (ets + stlets + arima) / 3) %>%
  mutate(COMB_weighted = combination_ensemble(ets, stlets, arima, 
                                              weights = "inv_var")) 
  
fc <- takeaway_models %>%
  forecast(h = "5 years")

fc %>%
  autoplot(aus_takeaway %>% filter(year(Month) > 2008),
           level = NULL) +
  labs(y = "$ billion",
       title = "Australian monthly expenditure on eating out")

fc %>%
  accuracy(aus_takeaway) %>%
  arrange(RMSE)




  
  
