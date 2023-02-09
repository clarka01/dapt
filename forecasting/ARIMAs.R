library("fpp3")

#Egyptian exports as a percentage of GDP from 1960 to 2017
global_economy %>% 
  filter(Code == "EGY")%>%
  autoplot(Exports) +
  labs(y = "% of GDP", title = "Egyptian Exports")

fit <- global_economy %>%
  filter(Code == "EGY") %>%
  model(ARIMA(Exports))
report(fit)                                                       

gg_tsresiduals(fit)


augment(fit) %>%
  features(.innov, ljung_box, lag = 10, dof = 4)


egypt <- global_economy %>% filter(Code == "EGY")
egypt %>% ACF(Exports) %>% autoplot()
egypt %>% PACF(Exports) %>% autoplot()

global_economy %>% filter(Code == "EGY") %>%
  gg_tsdisplay(Exports, plot_type='partial')

fit2 <- global_economy %>%
  filter(Code == "EGY") %>%
  model(ARIMA(Exports ~ pdq(4,0,0)))
report(fit2)

fit3 <- global_economy %>%
  filter(Code == "EGY") %>%
  model(ARIMA(Exports ~ pdq(2,0,0)))
report(fit3)

fit4 <- global_economy %>%
  filter(Code == "EGY") %>%
  model(ARIMA(Exports ~ pdq(p=1:3, d=1, q=0:2)))
report(fit4)

#Central African Republic exports
global_economy %>%
  filter(Code == "CAF") %>%
  autoplot(Exports) +
  labs(title="Central African Republic exports",
       y="% of GDP")

global_economy %>%
  filter(Code == "CAF") %>%
  gg_tsdisplay(difference(Exports), plot_type='partial')

caf_fit <- global_economy %>%
  filter(Code == "CAF") %>%
  model(arima210 = ARIMA(Exports ~ pdq(2,1,0)),
        arima013 = ARIMA(Exports ~ pdq(0,1,3)),
        stepwise = ARIMA(Exports),
        search = ARIMA(Exports, stepwise=FALSE))

caf_fit %>% pivot_longer(!Country, names_to = "Model name",
                         values_to = "Orders")

glance(caf_fit) %>% arrange(AICc) %>% select(.model:BIC)

caf_fit %>%
  select(search) %>%
  gg_tsresiduals()

augment(caf_fit) %>%
  filter(.model=='search') %>%
  features(.innov, ljung_box, lag = 10, dof = 3)

caf_fit %>%
  forecast(h=5) %>%
  filter(.model=='search') %>%
  autoplot(global_economy)
