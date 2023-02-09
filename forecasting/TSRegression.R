library("fpp3")

# Recall that the beer production data had trend and seasonality
recent_production <- aus_production %>%
  filter(year(Quarter) >= 1992)
recent_production %>%
  autoplot(Beer) +
  labs(y = "Megalitres",
       title = "Australian quarterly beer production")

# In TSLM, trend and seasona are keywords 
#that can be used to create a predictor

fit_beer <- recent_production %>%
  model(TSLM(Beer ~ trend() + season()))
report(fit_beer)

augment(fit_beer) %>%
  ggplot(aes(x = Quarter)) +
  geom_line(aes(y = Beer, colour = "Data")) +
  geom_line(aes(y = .fitted, colour = "Fitted")) +
  labs(x = "Quarter", y = "Megalitres",
       title = "Quarterly Beer Production")

augment(fit_beer) %>%
  ggplot(aes(x = Beer, y = .fitted,
             colour = factor(quarter(Quarter)))) +
  geom_point() +
  ylab("Fitted") + xlab("Actual values") +
  ggtitle("Quarterly beer production") +
  scale_colour_brewer(palette="Dark2", name="Quarter") +
  geom_abline(intercept=0, slope=1)

gg_tsresiduals(fit_beer)
augment(fit_beer) %>% features(.innov, ljung_box, lag=24, dof=6)

# When you have a good model, the forecast function can be applied to the fitted model
fc_beer <- forecast(fit_beer)
fc_beer %>%
  autoplot(recent_production) +
  ggtitle("Forecasts of beer production using regression") +
  ylab("megalitres")

fit_beer2 <- recent_production %>%
  model(ARIMA(Beer ~ trend() + season()))
report(fit_beer2)
gg_tsresiduals(fit_beer2)
augment(fit_beer2) %>% features(.innov, ljung_box, lag=24, dof=6)

fc_beer2 <- forecast(fit_beer2)
fc_beer2 %>%
  autoplot(recent_production) +
  ggtitle("Forecasts of beer production using regression") +
  ylab("megalitres")

bind_rows(
  fit_beer %>% accuracy(),
  fit_beer2 %>% accuracy()
 )

#US Personal Consumption and Income
#yt = quarterly percentage changes (growth rate) in personal consumption expenditure
#xt= personal disposable income 
#from 1970 Q1 to 2019 Q2

#forecast changes in expenditure based on changes in income. 
us_change %>%
  pivot_longer(c(Consumption, Income),
               names_to = "var", values_to = "value") %>%
  ggplot(aes(x = Quarter, y = value)) +
  geom_line() +
  facet_grid(vars(var), scales = "free_y") +
  labs(title = "US consumption and personal income",
       y = "Quarterly % change")


fit_arma <- us_change %>%
  model(ARIMA(Consumption ~ Income))
report(fit_arma)
gg_tsresiduals(fit_arma)

#regression residuals 
epsilon_t <- residuals(fit_arma, type = "regression")
gg_tsdisplay(epsilon_t, plot_type='partial', lag=24)

# ARMA residuals
e_t <- residuals(fit_arma, type = "innovation")
gg_tsdisplay(e_t, plot_type='partial', lag=24)

#forecast?
