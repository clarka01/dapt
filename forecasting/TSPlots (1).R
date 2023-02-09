install.packages("fpp3")
library("fpp3")

# tsibble objects

library(tsibble)
y <- tsibble(Year = 2015:2019, Observation = c(123,39,78,52,110), index = Year)

y

# PBS is a tsibble object containing monthly
# data on Medicare Australia prescription data
PBS

# We can use filter to choose just A10 prescriptions
# This is one Anatomical Therapeutic Chemical (ATC) index
PBS %>%
  filter(ATC2=="A10")

# We can use the select function to choose certain columns
PBS %>%
  filter(ATC2=="A10") %>%
  select(Month, Concession, Type, Cost)

# We can use the summarise function to get the sum  
# of all costs in a given month
PBS %>%
  filter(ATC2=="A10") %>%
  select(Month, Concession, Type, Cost) %>%
  summarise(TotalC = sum(Cost))

# We can use the mutate function to create a new
# column called cost
PBS %>%
  filter(ATC2=="A10") %>%
  select(Month, Concession, Type, Cost) %>%
  summarise(TotalC = sum(Cost)) %>%
  mutate(Cost = TotalC/1e6)

# Lastly, we can assign the res
PBS %>%
  filter(ATC2=="A10") %>%
  select(Month, Concession, Type, Cost) %>%
  summarise(TotalC = sum(Cost)) %>%
  mutate(Cost = TotalC/1e6) -> a10

# Read a csv file
install.packages("readr")
library(readr)
prison <- readr::read_csv("https://OTexts.com/fpp3/extrafiles/prison_population.csv")

# Create a tsibble object turning the date starting a quarter into quarters and choosing certain columns
prison <- prison %>%
  mutate(quarter = yearquarter(date)) %>%
  select(-date) %>%
  as_tsibble(key = c(state, gender, legal, indigenous), index = quarter)

prison

# Time series plots
melsyd_economy <- ansett %>%
  filter(Airports == "MEL-SYD", Class=="Economy")
melsyd_economy %>%
  autoplot(Passengers) +
  labs(title = "Ansett economy class passengers", subtitle = "Melbourne-Sydney") +
  xlab("Year")

a10 %>% autoplot(Cost) +
  ggtitle("Antidiabetic drug sales") +
  ylab("$ million") + xlab("Year")

# Looking for seasonanility
a10 %>% gg_season(Cost, labels = "both") +
  ylab("$ million") +
  ggtitle("Seasonal plot: antidiabetic drug sales")

a10 %>%
  gg_subseries(Cost) +
  ylab("$ million") +
  xlab("Year") +
  ggtitle("Seasonal subseries plot: antidiabetic drug sales")

vic_elec %>% gg_season(Demand, period="day") + theme(legend.position = "none")

vic_elec %>% gg_season(Demand, period="week") + theme(legend.position = "none")

vic_elec %>% gg_season(Demand, period="year")

holidays <- tourism %>%
  filter(Purpose == "Holiday") %>%
  group_by(State) %>%
  summarise(Trips = sum(Trips))

holidays

holidays %>% autoplot(Trips) +
  ylab("thousands of trips") + xlab("Year") +
  ggtitle("Australian domestic holiday nights")

holidays %>% gg_season(Trips) +
  ylab("thousands of trips") +
  ggtitle("Australian domestic holiday nights")

holidays %>%
  gg_subseries(Trips) + ylab("thousands of trips") +
  ggtitle("Australian domestic holiday nights")


# Cross-correlation
vic_elec %>%
  filter(year(Time) == 2014) %>%
  autoplot(Demand) +
  xlab("Year: 2014") + ylab(NULL) +
  ggtitle("Half-hourly electricity demand: Victoria, Australia")

vic_elec %>%
  filter(year(Time) == 2014) %>%
  autoplot(Temperature) +
  xlab("Year: 2014") + ylab(NULL) +
  ggtitle("Half-hourly temperatures: Melbourne, Australia")

vic_elec %>%
  filter(year(Time) == 2014) %>%
  ggplot(aes(x = Temperature, y = Demand)) +
  geom_point() +
  ylab("Demand (GW)") + xlab("Temperature (Celsius)")

visitors <- tourism %>%
  group_by(State) %>%
  summarise(Trips = sum(Trips))

visitors %>%
  ggplot(aes(x = Quarter, y = Trips)) +
  geom_line() +
  facet_grid(vars(State), scales = "free_y") +
  ylab("Number of visitor nights each quarter (millions)")

visitors %>%
  spread(State, Trips) %>%
  GGally::ggpairs(columns = 2:9)

# Auto-correlation
recent_production <- aus_production %>%
  filter(year(Quarter) >= 1992)

recent_production %>% gg_lag(Beer, geom="point")

recent_production %>% ACF(Beer, lag_max = 9)

recent_production %>% ACF(Beer) %>% autoplot()

# Trends and seasonality affect ACF
a10 %>% ACF(Cost, lag_max = 48) %>% autoplot()

# When there is no auto-correlation
set.seed(30)
y <- tsibble(sample = 1:50, wn = rnorm(50), index = sample)
y %>% autoplot(wn) + ggtitle("White noise")

y %>% ACF(wn) %>% autoplot()

# Code to play with a time series
help(us_employment)

us_retail_employment <- us_employment %>%
  filter(year(Month) >= 1990, Title == "Retail Trade") %>%
  select(-Series_ID)

us_retail_employment

us_retail_employment %>%
  autoplot(Employed) +
  xlab("Year") + ylab("Persons (thousands)") +
  ggtitle("Total employment in US retail")

frequency(us_retail_employment)

us_retail_employment %>% gg_season(Employed, labels = "both") +
  ylab("Persons (thousands)") +
  ggtitle("Seasonal plot")

us_retail_employment %>%
  gg_subseries(Employed) +
  ylab("Persons (thousands)") +
  ggtitle("Seasonal subseries plot")

us_retail_employment %>% ACF(Employed) %>% autoplot() +
  xlab("Lag")

us_retail_employment %>% gg_lag(Employed, geom="point")
