library("fpp3")

google_stock <- gafa_stock %>%
  filter(Symbol == "GOOG") %>%
  mutate(day = row_number()) %>%
  update_tsibble(index = day, regular = TRUE)

# Filter the year of interest
google_2015 <- google_stock %>% filter(year(Date) == 2015)

# Data with trend and/or seasonality are called non-stationary
google_2015 %>% autoplot(Close)+
  labs(y = "Google closing stock price", x = "Day")

google_2015 %>% ACF(Close) %>% autoplot()


# We can use differencing to make the resulting series stationary
google_2015 %>%
  mutate(diff_close = difference(Close)) -> google_2015
  
google_2015 %>% autoplot(diff_close)

google_2015 %>% ACF(diff_close) %>% autoplot()

google_2015 %>%
  features(diff_close, ljung_box, lag = 10)


a10 <- PBS %>%
  filter(ATC2 == "A10") %>%
  summarise(Cost = sum(Cost)/1e6)

a10 %>% autoplot(Cost)

a10 %>% autoplot(log(Cost))
a10 %>% autoplot(log(Cost) %>% difference(12))+
  ylab("Differenced log sales")

h02 <- PBS %>%
  filter(ATC2 == "H02") %>%
  summarise(Cost = sum(Cost)/1e6)
h02 %>% autoplot(Cost)
h02 %>% autoplot(log(Cost))

h02 %>% autoplot(log(Cost) %>% difference(12))+
  ylab("Seasonally Differenced log sales")

h02 %>% autoplot(log(Cost) %>% difference(12) %>% difference(1))+
  ylab("Doubly Differenced log sales")


# The Kwiatkowski, Phillips, Schmidt, & Shin (KPSS) test tells us if we have non-stationary data. 
# The goog data fails
google_2015 %>%
  features(Close, unitroot_kpss)

# but the differenced data passes
google_2015 %>%
  features(diff_close, unitroot_kpss)

# unitroot_ndiffs tells us whether we need single or double differencing at lag 1 to pass the KPSS test
google_2015 %>%
  features(Close, unitroot_ndiffs)




# unitroot_nsdiffs tells us whether we need single or double seasonal differencing to pass the KPSS test
a10 %>%
  features(log(Cost), unitroot_nsdiffs)

a10 <-  a10 %>%
  mutate(diff12_log_sales = difference(log(Cost), 12))

a10 %>%
  features(diff12_log_sales, unitroot_ndiffs)

a10 %>%
  features(diff12_log_sales, unitroot_kpss)

h02 %>%
  features(log(Cost), unitroot_nsdiffs)

h02 <-  h02 %>%
  mutate(diff12_log_sales = difference(log(Cost), 12))

h02 %>%
  features(diff12_log_sales, unitroot_ndiffs)

h02 <-  h02 %>%
  mutate(diff1_diff12_log_sales = difference(diff12_log_sales, 1))
h02 %>%
  features(diff1_diff12_log_sales, unitroot_ndiffs)

h02 %>%
  features(diff1_diff12_log_sales, unitroot_kpss)



