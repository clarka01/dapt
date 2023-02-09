library(lubridate)
library(tidyverse)
library(kableExtra)

#PO create object PO2018edited = VCU_Class_PO_fis18
PO2018edited <- VCU_Class_PO_fis18

#-------------------------------------------------------------------------------
#PO change format of a single date column (character format:DD-MM-YYYY 00:00:00) from character to date (YYYY-MM-DD)
# using library(lubridate)
PO2018edited$`Requisition submitted date` <- as.Date(dmy_hms(PO2018edited$`Requisition submitted date`))
PO2018edited$`Requisition Approved Date` <- as.Date(dmy_hms(PO2018edited$`Requisition Approved Date`))
PO2018edited$`ORDERDATE` <- as.Date(dmy_hms(PO2018edited$`ORDERDATE`))
class(PO2018edited$`ORDERDATE`)

#PO remove 12 Federal Medicaid adjustments 
#filter extreme rows from A602 `Order #` EP2539756, EP2539757,  EP2539759, EP2539761, EP2539762, EP2539787
PO2018edited <- PO2018edited %>% 
  filter(!str_detect(`Order #`, "EP2539756")) %>% 
  filter(!str_detect(`Order #`, "EP2539757")) %>% 
  filter(!str_detect(`Order #`, "EP2539759")) %>% 
  filter(!str_detect(`Order #`, "EP2539761")) %>% 
  filter(!str_detect(`Order #`, "EP2539762")) %>% 
  filter(!str_detect(`Order #`, "EP2539787")) %>% 
  filter(!str_detect(`Order #`, "EP2797974")) %>% 
  filter(!str_detect(`Order #`, "EP2797975")) %>% 
  filter(!str_detect(`Order #`, "EP2797978")) %>% 
  filter(!str_detect(`Order #`, "EP2797980")) %>% 
  filter(!str_detect(`Order #`, "EP2797982")) %>% 
  filter(!str_detect(`Order #`, "EP2797983"))

# Remove all -$ orders as they are change orders, discounts, credits etc
#PO Count number of '-ve' in Total Cost:  
sum(PO2018edited$`Total Cost` < "0", na.rm=TRUE) # Ans 1425
#PO remove -ve = `Total Cost` as they are change orders, discounts, credits etc
# df <- df[df$A >= 0, ]
PO2018edited  <-   PO2018edited[PO2018edited$`Total Cost` >= 0, ]

#PO total number of records in PO2018edited 
nrow(PO2018edited) #Ans = 1945221

#PO reduce PO1018edited to distinct orders (new called PO2018editedDistinct)
PO2018editedDistinct <- distinct(PO2018edited, `Order #`,  .keep_all = TRUE)

# scatterplot to check data
GrpAsgnmtScat1 = ggplot(PO2018editedDistinct, aes(x=ORDERDATE, y=`Total Cost`)) + 
  geom_point()
GrpAsgnmtScat1

#make agency PO data
POa602_2018editedDistinct <- PO2018editedDistinct%>% filter(str_detect(`Entity Code`, "A602"))
POa701_2018editedDistinct <- PO2018editedDistinct%>% filter(str_detect(`Entity Code`, "A701"))
POa123_2018editedDistinct <- PO2018editedDistinct%>% filter(str_detect(`Entity Code`, "A123"))
POa301_2018editedDistinct <- PO2018editedDistinct%>% filter(str_detect(`Entity Code`, "A301"))





#-------------------------------------------------------------------------------
#Q1 total number of records in each

nrow(PO2018editedDistinct) #Agg Ans = 710534
nrow(POa602_2018editedDistinct) # A602 = 938
nrow(POa701_2018editedDistinct) # A701 = 11251
nrow(POa123_2018editedDistinct) # A123 = 4025
nrow(POa301_2018editedDistinct) # A301 = 4036

#-------------------------------------------------------------------------------
#Q2   Average time between order dates of purchases - two solutions

# 1st solution: Number of days between first (31-0ct-2017) and last  (01-Apr-2018) divide by number of rows/orders:
(as.numeric(max(PO2018editedDistinct$ORDERDATE) - min(PO2018editedDistinct$ORDERDATE))/nrow(PO2018editedDistinct)) # Aggregate Answer = 0.0005122908

#  2nd solution: Average time between order dates of purchases using dplyr:
TestTable[1,2]<- PO2018editedDistinct %>% 
  arrange(ORDERDATE) %>%
  summarize(avg = as.numeric(mean(diff(ORDERDATE)))) # Aggregate Answer = 0.000512

TestTable[2,2] <- POa602_2018editedDistinct %>% 
  arrange(ORDERDATE) %>%
  summarize(avg = as.numeric(mean(diff(ORDERDATE)))) # A602 Answer = 0.383

TestTable[3,2] <- POa701_2018editedDistinct %>% 
  arrange(ORDERDATE) %>%
  summarize(avg = as.numeric(mean(diff(ORDERDATE)))) #A701  Answer = 0.0323

TestTable[4,2] <- POa123_2018editedDistinct %>% 
  arrange(ORDERDATE) %>%
  summarize(avg = as.numeric(mean(diff(ORDERDATE)))) # A123 Answer = 0.0892

TestTable[5,2] <- POa301_2018editedDistinct %>% 
  arrange(ORDERDATE) %>%
  summarize(avg = as.numeric(mean(diff(ORDERDATE)))) # A301 Answer = 0.0890

TestTable[ ,1] <- c("Agg", "A602", "A701", "A123", "A301")


# Name the headers
names(TestTable) <- c('Agency', 'Ave_days')
TestTable

# Make Table #library("kableExtra")
TestTable %>%
  kbl() %>%
  kable_styling()


#-------------------------------------------------------------------------------
#Q3 How many PO orders qualify for at least one SWaM:

# new vector which is the sum of all SWAMS. Then make No Swams = 0, & Any Swams = 1
PO2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(PO2018editedDistinct[20:23], 1, sum))
PO2018editedDistinct$`All SWAM`[PO2018editedDistinct$`All SWAM` > 0] <- 1

# find total number of 'at least one SWaM categogy'
sum(PO2018editedDistinct$`All SWAM` == "0", na.rm=TRUE) # Not SWAM  =  467197
sum(PO2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # SWAM total =  228826   
# Number of PO Records   
nrow(PO2018editedDistinct) # = 710534    
# Number of NA in PO Records  
sum(is.na(PO2018editedDistinct$`All SWAM`)) # =  14511   
# NB Total SWaM = Total Not SWaM + Total SWaM + NA

# %SWAM = 228826 / 710540 x 100 = 32%    
# 32% of PO records are at least one SWaM category


#-------------------------------------------------------------------------------
#Q3 Method 2:  How many PO orders qualify for at least one SWaM:

#new column sum of all SWAMS, then if number of SWAM categories >0 then make 1
PO2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(PO2018editedDistinct[20:23], 1, sum))
PO2018editedDistinct$`All SWAM`[PO2018editedDistinct$`All SWAM` > 0] <- 1
# find number of PO's that are SWAM = 1
sum(PO2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # Ans = 228826

# find total number of orders
nrow(PO2018editedDistinct)   # Ans=710534
# Number of NA in PO Records  
sum(is.na(PO2018editedDistinct$`All SWAM`)) # =  14511   
# NB Total SWaM = Total Not SWaM + Total SWaM + NA

# %SWAM = 228826 / 710540 x 100 = 32%    
# 32% of PO records are at least one SWaM category



# Repeat for all Agencies:
POa602_2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(POa602_2018editedDistinct[20:23], 1, sum))
POa602_2018editedDistinct$`All SWAM`[POa602_2018editedDistinct$`All SWAM` > 0] <- 1
sum(POa602_2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # Ans = 497

nrow(POa602_2018editedDistinct)   # Ans=938


POa701_2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(POa701_2018editedDistinct[20:23], 1, sum))
POa701_2018editedDistinct$`All SWAM`[POa701_2018editedDistinct$`All SWAM` > 0] <- 1
sum(POa701_2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # Ans = 4571

nrow(POa701_2018editedDistinct)   # Ans=11251


POa123_2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(POa123_2018editedDistinct[20:23], 1, sum))
POa123_2018editedDistinct$`All SWAM`[POa123_2018editedDistinct$`All SWAM` > 0] <- 1
sum(POa123_2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # Ans = 2338

nrow(POa123_2018editedDistinct)   # Ans=4025


POa301_2018editedDistinct$`All SWAM`  <- data.frame( Sum_of_Swams = apply(POa301_2018editedDistinct[20:23], 1, sum))
POa301_2018editedDistinct$`All SWAM`[POa301_2018editedDistinct$`All SWAM` > 0] <- 1
sum(POa301_2018editedDistinct$`All SWAM` == "1", na.rm=TRUE) # Ans = 1427

nrow(POa301_2018editedDistinct)   # Ans=4036





#-------------------------------------------------------------------------------
#Q4 Create a table of the number of purchases by month using `Order Date`.
# Make Bar Chart of Count/Month 

# Aggregate -------------------------------
# take month out of ORDERDATE field & create 'ORDERDATE Month' column
PO2018editedDistinct$`Order Month` <-  month(PO2018editedDistinct$`ORDERDATE`)

# library(dplyr)
PO2018editedDistinctMonthCount <- PO2018editedDistinct %>%
  group_by(`Order Month`) %>%
  summarise(n_distinct(`Order #`))

# change header name
colnames(PO2018editedDistinctMonthCount)[2]<- "Total_Count_by_Month"

# Table of the number of purchases by month: PO2018editedDistinctMonthCount
#library("kableExtra")
PO2018editedDistinctMonthCount %>%
  kbl() %>%
  kable_styling()

POa602_2018editedDistinct


# A602 -------------------------------
# take month out of ORDERDATE field & create 'ORDERDATE Month' column
POa602_2018editedDistinct$`Order Month` <-  month(POa602_2018editedDistinct$`ORDERDATE`)

# library(dplyr)
PO2018a602editedDistinctMonthCount <- POa602_2018editedDistinct %>%
  group_by(`Order Month`) %>%
  summarise(n_distinct(`Order #`))

# change header name
colnames(PO2018a602editedDistinctMonthCount)[2]<- "Total_Count_by_Month"

# Table of the number of purchases by month: PO2018editedDistinctMonthCount
#library("kableExtra")
PO2018a602editedDistinctMonthCount %>%
  kbl() %>%
  kable_styling()

# A701 -------------------------------
# take month out of ORDERDATE field & create 'ORDERDATE Month' column
POa701_2018editedDistinct$`Order Month` <-  month(POa701_2018editedDistinct$`ORDERDATE`)

# library(dplyr)
PO2018a701editedDistinctMonthCount <- POa701_2018editedDistinct %>%
  group_by(`Order Month`) %>%
  summarise(n_distinct(`Order #`))

# change header name
colnames(PO2018a701editedDistinctMonthCount)[2]<- "Total_Count_by_Month"

# Table of the number of purchases by month: PO2018editedDistinctMonthCount
#library("kableExtra")
PO2018a701editedDistinctMonthCount %>%
  kbl() %>%
  kable_styling()


# A123 -------------------------------
# take month out of ORDERDATE field & create 'ORDERDATE Month' column
POa123_2018editedDistinct$`Order Month` <-  month(POa123_2018editedDistinct$`ORDERDATE`)

# library(dplyr)
PO2018a123editedDistinctMonthCount <- POa123_2018editedDistinct %>%
  group_by(`Order Month`) %>%
  summarise(n_distinct(`Order #`))

# change header name
colnames(PO2018a123editedDistinctMonthCount)[2]<- "Total_Count_by_Month"

# Table of the number of purchases by month: PO2018editedDistinctMonthCount
#library("kableExtra")
PO2018a123editedDistinctMonthCount %>%
  kbl() %>%
  kable_styling()


# A301 -------------------------------
# take month out of ORDERDATE field & create 'ORDERDATE Month' column
POa301_2018editedDistinct$`Order Month` <-  month(POa301_2018editedDistinct$`ORDERDATE`)

# library(dplyr)
PO2018a301editedDistinctMonthCount <- POa301_2018editedDistinct %>%
  group_by(`Order Month`) %>%
  summarise(n_distinct(`Order #`))

# change header name
colnames(PO2018a301editedDistinctMonthCount)[2]<- "Total_Count_by_Month"

# Table of the number of purchases by month: PO2018editedDistinctMonthCount
#library("kableExtra")
PO2018a301editedDistinctMonthCount %>%
  kbl() %>%
  kable_styling()





#-------------------------------------------------------------------------------
#save as .rda file
save(POa602_2018editedDistinct, file = 'POa602_2018editedDistinct.rda')
save(POa701_2018editedDistinct, file = 'POa701_2018editedDistinct.rda')
save(POa123_2018editedDistinct, file = 'POa123_2018editedDistinct.rda')
save(POa301_2018editedDistinct, file = 'POa301_2018editedDistinct.rda')
save(PO2018edited, file = 'PO2018edited.rda')
