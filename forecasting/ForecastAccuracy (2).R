# Let's plot the Swedish GDP
global_economy %>%
  filter(Country=="Sweden") %>%
  autoplot(GDP) +
  ggtitle("GDP for Sweden") + ylab("$US billions")

# We can do a simple time series linear regression of GDP versus time
fit <- global_economy %>%
  model(trend_model = TSLM(GDP ~ trend()))

# We can forecast with the linear model
fit %>% forecast(h = "3 years")

# and we can plot the forecasts after the observed data
# this includes prediction intervals
fit %>% forecast(h = "3 years") %>%
  filter(Country=="Sweden") %>%
  autoplot(global_economy) +
  ggtitle("GDP for Sweden") + ylab("$US billions")

# Set training data from 1992 to 2006
train <- aus_production %>% filter_index("1992 Q1" ~ "2006 Q4")

# We can fit a number of models at the same time
# MEAN forecasts the average value of the training data
# NAIVE forecasts the last value
# SNAIVE forecasts the value one seasonal period back
beer_fit <- train %>%
  model(
    Mean = MEAN(Beer),
    `Naïve` = NAIVE(Beer),
    `Seasonal naïve` = SNAIVE(Beer)
  )

# Let's look at the fitted values and the residuals
View(augment(beer_fit))

augment(beer_fit) %>%
  filter(.model=="Mean")

augment(beer_fit) %>%
  filter(.model=="Naïve")

augment(beer_fit) %>%
  filter(.model=="Seasonal naïve")

# Generate forecasts for 14 quarters
beer_fc <- beer_fit %>% forecast(h=14)

# Plot forecasts against actual values
# The SNAIVE forecast looks the best
beer_fc %>%
  autoplot(train, level = NULL) +
  autolayer(filter_index(aus_production, "2007 Q1" ~ .), color = "black") +
  ggtitle("Forecasts for quarterly beer production") +
  xlab("Year") + ylab("Megalitres") +
  guides(colour=guide_legend(title="Forecast"))

# Let's build a model for Google's stock price
# Re-index based on trading days because stocks aren't traded on the weekends
google_stock <- gafa_stock %>%
  filter(Symbol == "GOOG") %>%
  mutate(day = row_number()) %>%
  update_tsibble(index = day, regular = TRUE)

# Filter the year of interest
google_2015 <- google_stock %>% filter(year(Date) == 2015)

# Fit the models
google_fit <- google_2015 %>%
  model(
    Mean = MEAN(Close),
    `Naïve` = NAIVE(Close),
    Drift = NAIVE(Close ~ drift())
  )

# Produce forecasts for the 19 trading days in January 2015
google_fc <- google_fit %>% forecast(h = 19)

# We would really like to compare the forecasts to the actual Jan 2016 values
google_jan_2016 <- google_stock %>%
  filter(yearmonth(Date) == yearmonth("2016 Jan"))

google_fc <- google_fit %>% forecast(google_jan_2016)

# Plot the forecasts
google_fc %>%
  autoplot(google_2015, level = NULL) +
  autolayer(google_jan_2016, Close, color='black') +
  ggtitle("Google stock (daily ending 31 Dec 2015)") +
  xlab("Day") + ylab("Closing Price (US$)") +
  guides(colour=guide_legend(title="Forecast"))

# Let's take a look at the residuals for the Naive method
aug <- google_2015 %>% model(NAIVE(Close)) %>% augment()

aug %>% autoplot(.resid) + xlab("Day") + ylab("") +
  ggtitle("Residuals from naïve method")

aug %>%
  ggplot(aes(x = .resid)) +
  geom_histogram() +
  ggtitle("Histogram of residuals")

aug %>% ACF(.resid) %>% autoplot() + ggtitle("ACF of residuals")

# There is a shortcut to get these graphs for a fitted model using gg_tsresiduals
google_2015 %>% model(NAIVE(Close)) %>% gg_tsresiduals()

# We can also test for white noise in the residuals of the Mean model
# Box Pierce is a basic test using the squared residuals
aug %>% features(.resid, box_pierce, lag=10, dof=0)

# Ljung Box is a more advanced test that weights more recent residuals
aug %>% features(.resid, ljung_box, lag=10, dof=0)

# We can also try adding a drift to the model
fit <- google_2015 %>% model(RW(Close~drift()))

# tidy() gives you the parameters of the fitted model
fit %>% tidy()

# Let's test the drift model's residuals for white noise
augment(fit) %>% features(.resid, ljung_box, lag=10, dof=1)

# Cross-validation

# Let's fit a model to the beer consumption data
# We always want to train on part of the data and calculate accuracy on separate test data
recent_production <- aus_production %>% filter(year(Quarter) >= 1992)
beer_train <- recent_production %>% filter(year(Quarter) <= 2007)

beer_fit <- beer_train %>%
  model(
    Mean = MEAN(Beer),
    `Naïve` = NAIVE(Beer),
    `Seasonal naïve` = SNAIVE(Beer),
    Drift = RW(Beer ~ drift())
  )

beer_fc <- beer_fit %>%
  forecast(h = 10)

beer_fc %>%
  autoplot(filter(aus_production, year(Quarter) >= 1992), level = NULL) +
  xlab("Year") + ylab("Megalitres") +
  ggtitle("Forecasts for quarterly beer production") +
  guides(colour=guide_legend(title="Forecast"))

# The accuracy function only compares forecast versus actual values for the same time periods
accuracy(beer_fc, recent_production)

# Let's test the cross-validation accuracy of our models for the Google stock price
google_fit <- google_2015 %>%
  model(
    Mean = MEAN(Close),
    `Naïve` = NAIVE(Close),
    Drift = RW(Close ~ drift())
  )

google_fc <- google_fit %>%
  forecast(google_jan_2016)

google_fc %>%
  autoplot(rbind(google_2015,google_jan_2016), level = NULL) +
  xlab("Day") + ylab("Closing Price (US$)") +
  ggtitle("Google stock price (daily ending 6 Dec 13)") +
  guides(colour=guide_legend(title="Forecast"))

accuracy(google_fc, google_stock)

# Rather using one partition of the data into train and test sets
# We can using rolling forecasts

# Let's compare this rolling cross-validation accuracy
google_2015_tr <- google_2015 %>%
  slice(1:(n()-1)) %>%
  stretch_tsibble(.init = 3, .step = 1)
fc <- google_2015_tr %>%
  model(RW(Close ~ drift())) %>%
  forecast(h=1)

fc %>% accuracy(google_2015)

# to straight residual (training) accuracy
google_2015 %>% model(RW(Close ~ drift())) %>% accuracy()

# Lastly, how does the rolling cross-validation accuracy 
# change with longer forecast horizons
google_2015_tr <- google_2015 %>%
  slice(1:(n()-8)) %>%
  stretch_tsibble(.init = 3, .step = 1)

fc <- google_2015_tr %>%
  model(RW(Close ~ drift())) %>%
  forecast(h=8) %>%
  group_by(.id) %>%
  mutate(h = row_number()) %>%
  ungroup()

fc %>%
  accuracy(google_2015, by = "h") %>%
  ggplot(aes(x = h, y = RMSE)) + geom_point()
