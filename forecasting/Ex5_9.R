library(fpp3)
View(hh_budget)
frequency(hh_budget)

# time series plot
hh_budget %>%
  autoplot(Wealth) +
  labs(title = "Household Wealth") +
  xlab("Year")

# training set
hh_budget_tr <- hh_budget %>% filter(Year <= max(Year)-4)

# forecasting methods
fit <- hh_budget_tr %>%
  model(
    Mean=MEAN(Wealth),
    Naive= NAIVE(Wealth),
    Drift = RW(Wealth ~ drift())
   )

fc <- fit %>%
  forecast(h=4)
fc %>%
  autoplot(hh_budget, level=NULL)+
  xlab("Year")+ylab("Household budget")

# accuracy
fc %>% accuracy(hh_budget)

#cross-validation accuracy (optional)

hh_budget_tr_cc <- hh_budget_tr %>%
   stretch_tsibble(.init = 3, .step = 1)
 
 hh_budget_tr_cc %>%
   model(
     Mean=MEAN(Wealth),
     Naive= NAIVE(Wealth),
     Drift = RW(Wealth ~ drift())
   ) %>%
   forecast(h=4)%>%
   accuracy(hh_budget)

# residual diagnostics
 
 fit %>%
   filter(Country == "Australia") %>%
   select(Drift) %>%
   gg_tsresiduals()
 
 fit %>%
   filter(Country == "Canada") %>%
   select(Drift) %>%
   gg_tsresiduals()

 fit %>%
   filter(Country == "Japan") %>%
   select(Drift) %>%
   gg_tsresiduals()

 fit %>%
   filter(Country == "USA") %>%
   select(Drift) %>%
   gg_tsresiduals()


