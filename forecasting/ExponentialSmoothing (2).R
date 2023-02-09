library("fpp3")

# We can do better than using moving averages to smooth out noisy data
algeria_economy <- global_economy %>%
  filter(Country == "Algeria")
algeria_economy %>%
  autoplot(Exports) +
  ylab("Exports (% of GDP)") + xlab("Year")

# We can use exponential smoothing
fit <- algeria_economy %>%
  model(ETS(Exports ~ error("A") + trend("N") + season("N"), opt_crit = "mse"))

report(fit)

components(fit) %>%
  left_join(fitted(fit), by = c("Country", ".model", "Year"))

0.84*39.+ (1-0.84)*39.5
39.0 - 39.5

fit %>% gg_tsresiduals()


fc <- fit %>%
  forecast(h = 5)
fc %>%
  autoplot(algeria_economy) +
  geom_line(aes(y = .fitted, colour = "Fitted"), data = augment(fit)) +
  ylab("Exports (% of GDP)") + xlab("Year")


fit2 <- algeria_economy %>%
    model(
    STL(Exports)) %>%
  components()

fit2 %>% autoplot()


# We can exponentially smooth the level and the trend
# We can also dampen the trend
aus_economy <- global_economy %>%
  filter(Code == "AUS") %>%
  mutate(Pop = Population / 1e6)
autoplot(aus_economy, Pop) +
  labs(y = "Millions", title = "Australian population")

fit_holt <- aus_economy %>%
  model(
    AAN = ETS(Pop ~ error("A") + trend("A") + season("N"))
  )
fc <- fit_holt %>% forecast(h = 10)
report(fit_holt)

aus_economy %>%
  model(
    `Holt's method` = ETS(Pop ~ error("A") + trend("A") + season("N")),
    `Damped Holt's method` = ETS(Pop ~ error("A") + trend("Ad", phi = 0.9) + season("N"))
    )%>%
  forecast(h = 15) %>%
  autoplot(aus_economy, level = NULL) +
  ggtitle("Forecasts from Holt's method") + xlab("Year") +
  ylab("Population of Australia (millions)") +
  guides(colour = guide_legend(title = "Forecast"))

# What approach would work for this data?

aus_economy %>%
  stretch_tsibble(.init = 10) %>%
  model(
    Holt = ETS(Pop ~ error("A") + trend("A") + season("N")),
    Damped = ETS(Pop ~ error("A") + trend("Ad") + season("N"))
  ) %>%
  forecast(h = 1) %>%
  accuracy(aus_economy)


algeria_economy %>%
  stretch_tsibble(.init = 10) %>%
  model(
    SES = ETS(Exports ~ error("A") + trend("N") + season("N")),
    Holt = ETS(Exports ~ error("A") + trend("A") + season("N")),
    Damped = ETS(Exports ~ error("A") + trend("Ad") + season("N"))
    ) %>%
  forecast(h = 1) %>%
  accuracy(algeria_economy)

tidy(fit_cv)

fit_holt <- algeria_economy %>%
    model(
        Holt = ETS(Exports ~ error("A") + trend("A") + season("N"))
    ) 
fit_damped <- algeria_economy %>%
  model(
    Damped = ETS(Exports ~ error("A") + trend("Ad") + season("N"))
  )   
fit_SES <- algeria_economy %>%
  model(
    SES = ETS(Exports ~ error("A") + trend("N") + season("N"))
  )  
report(fit_SES)
report(fit_holt)
report(fit_damped)



# We can add additive or multiplicative seasonality
view(tourism)
aus_holidays <- tourism %>%
  filter(Purpose == "Holiday") %>%
  summarise(Trips = sum(Trips)/1e3)
fit <- aus_holidays %>%
  model(
    additive = ETS(Trips ~ error("A") + trend("A") + season("A")),
    multiplicative = ETS(Trips ~ error("M") + trend("A") + season("M"))
  )
fc <- fit %>% forecast(h = "3 years")


fc %>%
  autoplot(aus_holidays, level = NULL) + xlab("Year") +
  ylab("Overnight trips (millions)") +
  scale_color_brewer(type = "qual", palette = "Dark2")

#comparison
fit_a <- aus_holidays %>%
  model(
    additive = ETS(Trips ~ error("A") + trend("A") + season("A"))
    )

fit_m <- aus_holidays %>%
  model(
    multiplicative = ETS(Trips ~ error("M") + trend("A") + season("M"))
  )

report(fit_a)
report(fit_m)


# The ETS function can do all these things
aus_holidays <- tourism %>%
  filter(Purpose == "Holiday") %>%
  summarise(Trips = sum(Trips)/1e3)
fit_auto <- aus_holidays %>%
  model(ETS(Trips))
report(fit_auto)

# model selection by BIC
fit_bic <- aus_holidays %>%
  model(ETS(Trips, ic="bic"))
report(fit_bic)

# We can see the components of an ETS model like we did in decomposition
components(fit_auto) %>%
  autoplot() +
  ggtitle("ETS(M,N,A) components")

# model diagostics
fit_auto %>%
   gg_tsresiduals()

# prediction intervals
fit_auto %>%
  forecast(h = 8) %>%
  autoplot(aus_holidays) +
  labs(title="Australian domestic tourism",
       y="Overnight trips (millions)")

#residuals
augment(fit_auto) %>%
  autoplot(.innov)+
  ylab("Innovation residuals") + xlab("Quarter")






  

