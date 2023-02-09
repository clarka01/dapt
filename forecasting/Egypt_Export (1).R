library("fpp3")

#Egyptian exports as a percentage of GDP from 1960 to 2017
egypt <- global_economy %>% 
  filter(Code == "EGY")
  
egypt %>%
  autoplot(Exports) +
  labs(y = "% of GDP", title = "Egyptian Exports")

fit <- egypt %>%
  model(ARIMA(Exports))
report(fit)                                                       
gg_tsresiduals(fit)


fc <- fit %>% forecast(h = 5)
fc %>% autoplot(egypt)
accuracy(fit)

egypt %>%
  gg_tsdisplay(Exports, plot_type='partial')

fit2 <- egypt %>%
  model(ARIMA(Exports ~ pdq(4,0,0)))
report(fit2)
gg_tsresiduals(fit2)

#
fit22 <- egypt %>%
  model(ARIMA(Exports ~ pdq(4,0,0), fixed=c(NA,0,0,NA,NA)))
report(fit22)
gg_tsresiduals(fit22)

fc22 <- fit22 %>% forecast(h = 5)
fc22 %>% autoplot(egypt)
accuracy(fit22)
