library(fpp3)

us_economy <- global_economy %>%
  filter(Code == "USA")
us_economy %>%
  autoplot(GDP)

lambda <- us_economy %>%
  features(GDP, features = guerrero) %>%
  pull(lambda_guerrero)
lambda

us_economy %>%
  autoplot(box_cox(GDP, lambda))

us_economy %>%  
     features(box_cox(GDP, lambda), unitroot_ndiffs)

fit <- us_economy %>%
  model(ARIMA(box_cox(GDP, lambda)))
report(fit)


us_economy %>%  
  features(box_cox(GDP, lambda), unitroot_ndiffs)

us_economy %>%
  gg_tsdisplay(difference(box_cox(GDP, lambda)), plot_type='partial')

fit2 <- us_economy %>%
  model(
arima210 = ARIMA(box_cox(GDP, lambda) ~ pdq(2, 1, 0))
)
report(fit2)

fit2 %>% pivot_longer(!Country, names_to = "Model name", values_to = "Orders")

glance(fit2) %>% arrange(AICc) #%>%select(.model,AICc)

fit %>%  gg_tsresiduals()
fit %>%
  forecast(h = 10) %>%
  autoplot(us_economy)

fit1 <- us_economy %>% model(ARIMA(GDP))
fit1 %>%
  forecast(h = 10) %>%
  autoplot(us_economy)


us_economy %>%
  model(
    ARIMA(GDP),
    ARIMA(box_cox(GDP, lambda))
  ) %>%
  forecast(h = 20) %>%
  autoplot(us_economy)

us_economy %>%
  model(ETS(GDP)) %>%
  forecast(h = 10) %>%
  autoplot(us_economy)
