library("fpp3")

# US retail data shows clear trend and seasonability
us_retail_employment <- us_employment %>%
  filter(year(Month) >= 1990, Title == "Retail Trade") %>%
  select(-Series_ID)
us_retail_employment %>%
  autoplot(Employed) +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

# Decomposition methods allow us to break time series into their components
dcmp <- us_retail_employment %>%
  model(STL(Employed))
components(dcmp)

# Let's compare the trend-cycle component to the full data
us_retail_employment %>%
  autoplot(Employed, color='gray') +
  autolayer(components(dcmp), trend, color='red') +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

# and we can plot all the components
components(dcmp) %>% autoplot() + xlab("Year")

# The trend-cycle component and the remainder combined are called the seasonally-adjusted series
us_retail_employment %>%
  autoplot(Employed, color='gray') +
  autolayer(components(dcmp), season_adjust, color='blue') +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

# Let's see how we can build a decomposition 

# Time series data is often noisy
global_economy %>%
  filter(Country == "Australia") %>%
  autoplot(Exports) +
  xlab("Year") + ylab("% of GDP") +
  ggtitle("Total Australian exports")

# A moving average can smooth out the noise using the ma function
aus_exports <- global_economy %>%
  filter(Country == "Australia") %>%
  mutate(
    MA5 = slide_dbl(Exports, mean, .size = 5, .align = "center")
  )

aus_exports %>%
  autoplot(Exports) +
  autolayer(aus_exports, MA5, color='red') +
  xlab("Year") + ylab("Exports (% of GDP)") +
  ggtitle("Total Australian exports") +
  guides(colour=guide_legend(title="series"))

# Let's compare different window lengths
aus_exports <- global_economy %>%
  filter(Country == "Australia") %>%
  mutate(
    MA3 = slide_dbl(Exports, mean, .size = 3, .align = "center"),
    MA5 = slide_dbl(Exports, mean, .size = 5, .align = "center"),
    MA7 = slide_dbl(Exports, mean, .size = 7, .align = "center")
  )

aus_exports %>%
  autoplot(Exports) +
  autolayer(aus_exports, MA3, color='blue') +
  autolayer(aus_exports, MA5, color='red') +
  autolayer(aus_exports, MA7, color='green') +
  xlab("Year") + ylab("Exports (% of GDP)") +
  ggtitle("Total Australian exports") 

# Remember our US retail data
us_retail_employment_ma %>%
  autoplot(Employed, color='gray') +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

# A moving average equal to twice the seasonal frequency can reveal the trend
us_retail_employment_ma <- us_retail_employment %>%
  mutate(
    `12-MA` = slide_dbl(Employed, mean, .size = 12, .align = "cr"),
    `2x12-MA` = slide_dbl(`12-MA`, mean, .size = 2, .align = "cl")
  )

us_retail_employment_ma %>%
  autoplot(Employed, color='gray') +
  autolayer(us_retail_employment_ma, vars(`2x12-MA`), color='red') +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

# Let's take the trend out
us_retail_employment_ma <- us_retail_employment_ma %>%
  mutate(
    trend = `2x12-MA`,
    detrend = Employed - trend
  )

us_retail_employment_ma %>%
  autoplot(detrend, series="Detrended") +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")
  

# A moving average equal to the seasonal frequency can de-seasonalize
us_retail_employment_ma <- us_retail_employment_ma %>%
  mutate(
    deseasonalize = slide_dbl(detrend, mean, .size = 12, .align = "cr"),
    seasonality = detrend - deseasonalize,
    remainder = deseasonalize
  )

# and plot the remainder
us_retail_employment_ma %>%
  autoplot(remainder, series="Remainder") +
  xlab("Year") + ylab("New orders index") +
  ggtitle("Electrical equipment manufacturing (Euro area)") 

# and plot the seasonality
us_retail_employment_ma %>%
  autoplot(seasonality, series="Seasonality") +
  xlab("Year") + ylab("New orders index") +
  ggtitle("Electrical equipment manufacturing (Euro area)") 


# Classical time series decomposition uses moving averages to deconstruct a time series into trend, season, and remainder components
# Step 1 - calculate the trend component with an MA
# Step 2 - deduct the trend component from the time series (de-trend)
# Step 3 - calculate the average of the de-trended series for each season
# Step 4 - deduct the trend and season components from the time series
us_retail_employment %>%
  model(classical_decomposition(Employed, type = "additive")) %>%
  components() %>%
  autoplot() + xlab("Year") +
  ggtitle("Classical additive decomposition of total US retail employment")

# x11 is an alternative approach
install.packages("seasonal")
library(seasonal)
x11_dcmp <- us_retail_employment %>%
  model(x11 = feasts:::X11(Employed, type = "additive")) %>%
  components()
autoplot(x11_dcmp) + xlab("Year") +
  ggtitle("Additive X11 decomposition of US retail employment in the US")

# and allows you to access the components
x11_dcmp %>%
  ggplot(aes(x = Month)) +
  geom_line(aes(y = Employed, colour = "Data")) +
  geom_line(aes(y = season_adjust, colour = "Seasonally Adjusted")) +
  geom_line(aes(y = trend, colour = "Trend")) +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail") +
  scale_colour_manual(values=c("gray","blue","red"),
                      breaks=c("Data","Seasonally Adjusted","Trend"))

# SEATS decomposition can be used with quarterly and monthly data
seats_dcmp <- us_retail_employment %>%
  model(seats = feasts:::SEATS(Employed)) %>%
  components()
autoplot(seats_dcmp) + xlab("Year") +
  ggtitle("SEATS decomposition of total US retail employment")

# STL decomposition is probably the most robust method
us_retail_employment %>%
  model(STL(Employed ~ trend(window=7) + season(window='periodic'),
            robust = TRUE)) %>%
  components() %>%
  autoplot()
