library(fpp3)
#view(aus_retail)

set.seed(12345678)
myseries <- aus_retail %>%
  filter(`Series ID` == sample(aus_retail$`Series ID`, 1))
myseries %>% autoplot(Turnover)

#a.	Why is multiplicative seasonality necessary for this series? 
#The variation in the seasonal pattern increases as the level of the series rises

#b b.	Apply Holt-Winters' multiplicative method to the data. 
#Experiment with making the trend damped.

fit <- myseries %>%
  model(
    hw = ETS(Turnover ~ error("M") + trend("A") + season("M")),
    hwdamped = ETS(Turnover ~ error("M") + trend("Ad") + season("M"))
  )

#c.	Compare the RMSE of the one-step forecasts from the two methods. 
#Which do you prefer?

fc <- fit %>% forecast(h = 36)
fc %>% autoplot(myseries)
accuracy(fit)

#The non-damped method is doing slightly better (on RMSE), 
#but the damped method is doing better on most other scores. 

#d.	Check that the residuals from the best method look like white noise.
fit %>%
  select("hwdamped") %>%
  gg_tsresiduals()

fit %>%
  select("hwdamped") %>%
  report()


augment(fit) %>%
  filter(.model == "hwdamped") %>%
  features(.innov, ljung_box, dof = 17, lag = 48)

#e.	Now find the test set RMSE, while training the model to the end of 2010. 
#Can you beat the seasonal naïve approach from Exercise 7 in Section 5.10?
myseries %>%
  filter(year(Month) < 2011) %>%
  model(
    snaive = SNAIVE(Turnover),
    hw = ETS(Turnover ~ error("M") + trend("A") + season("M")),
    hwdamped = ETS(Turnover ~ error("M") + trend("Ad") + season("M"))
  ) %>%
  forecast(h = "7 years") %>%
  accuracy(myseries)

#cross validation
myseries %>%
  stretch_tsibble(.init = 10) %>%
  model(
    Holts = ETS(Turnover ~ error("M") + trend("A") + season("M")),
    Damped = ETS(Turnover ~ error("M") + trend("Ad") + season("M"))
  ) %>%
  forecast(h =1) %>%
  accuracy(myseries)

