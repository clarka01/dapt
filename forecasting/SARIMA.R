library("fpp3")

# SARIMA

#monthly US employment data for leisure and hospitality jobs 
#from January 2001 to September 2019

leisure <- us_employment %>%
  filter(Title == "Leisure and Hospitality",
         year(Month) > 2000) %>%
  mutate(Employed = Employed/1000) %>%
  select(Month, Employed)

autoplot(leisure, Employed) +
  labs(title = "US employment: leisure and hospitality",
       y="Number of people (millions)")
view(leisure)

leisure %>%
  gg_tsdisplay(difference(Employed, 12),
               plot_type='partial', lag=36) +
  labs(title="Seasonally differenced", y="")


leisure %>%
  gg_tsdisplay(difference(Employed, 12) %>% difference(),
               plot_type='partial', lag=36) +
  labs(title = "Double differenced", y="")

leisure %>%
  features(difference(Employed, 12) %>% difference(),unitroot_kpss)
        
fit <- leisure %>%
  model(
    auto = ARIMA(Employed, stepwise = FALSE, approx = FALSE)
  )
report(fit)
gg_tsresiduals(fit)
augment(fit) %>% features(.innov, ljung_box, lag=24, dof=5)

fit1 <- leisure %>%
  model(
    arima210011 = ARIMA(Employed ~ pdq(2,1,0) + PDQ(0,1,1)),
  )
report(fit1)
gg_tsresiduals(fit1)
augment(fit1) %>% features(.innov, ljung_box, lag=24, dof=4)


fit2<- leisure %>%
  model(
    arima012011 = ARIMA(Employed ~ pdq(0,1,2) + PDQ(0,1,1)),
    )
report(fit2)
gg_tsresiduals(fit2)
augment(fit2) %>% features(.innov, ljung_box, lag=24, dof=4)

 
train <-  leisure %>%
  filter(year(Month) < 2019)
view(train)

fit3 <- train %>%
  model(
    arima012011 = ARIMA(Employed ~ pdq(0,1,2) + PDQ(0,1,1)),
    arima210011 = ARIMA(Employed ~ pdq(2,1,0) + PDQ(0,1,1)),
    auto210111 = ARIMA(Employed ~ pdq(2,1,0) + PDQ(1,1,1))
  )

fc <- fit3 %>%
  forecast(h="9 months")
fc %>%
  accuracy(leisure) %>%
  select(.model, .type, RMSE)

forecast(fit3, h=36) %>%
  filter(.model=='auto210111') %>%
  autoplot(leisure) +
  labs(title = "US employment: leisure and hospitality",
       y="Number of people (millions)")

# Let's compare the Seasonal ARIMA and ETS models


leisure %>%
  slice(-n()) %>%
  stretch_tsibble(.init = 10) %>%
  model(
    ets = ETS(Employed),
    arima = ARIMA(Employed ~ pdq(2,1,0) + PDQ(1,1,1))
  ) %>%
  forecast(h = 1) %>%
  accuracy(leisure)


