library(lubridate)
library(tidyverse)
library(kableExtra)
library(busdater)
library(reshape2)
library(ggplot2)
library(dplyr)
library(tidyr)


#PO 
#POJoin all years
PO18 <- VCU_Class_PO_fis18

#----------------------------------------------------------------
#Change fields with Dates from Character fields to Date Fields

#PO change format of a single date column (character format:DD-MM-YYYY 00:00:00) from character to date (YYYY-MM-DD)
# using library(lubridate)
PO18$`Requisition submitted date` <- as.Date(dmy_hms(PO18$`Requisition submitted date`))
PO18$`Requisition Approved Date` <- as.Date(dmy_hms(PO18$`Requisition Approved Date`))
PO18$`ORDERDATE` <- as.Date(dmy_hms(PO18$`ORDERDATE`))
#Confirm change to date filed
class(PO18$`Requisition submitted date`)
class(PO18$`Requisition Approved Date`)
class(PO18$`ORDERDATE`)

#----------------------------------------------------------------
#to check: show all headers and their data types
str(PO18)

#--------------------------------------------------------------------------------------------
#make agency PO data
PO18 <-VCU_Class_PO_fis18









AggregateR2 <- PO18
AggR2 <- PO18
A602R2 <- PO18%>% filter(str_detect(`Entity Code`, "A602"))
A701R2 <- PO18%>% filter(str_detect(`Entity Code`, "A701"))
A123R2 <- PO18%>% filter(str_detect(`Entity Code`, "A123"))
A301R2 <- PO18%>% filter(str_detect(`Entity Code`, "A301"))





#-------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#1. Plot a histogram of total cost.  Is the distribution skewed or approximately normal?

#Unadjusted Aggregate showing effect of outliers
histinfo<-hist(AggregateR2$`Total Cost`)
histinfo

AggregateR2na <- AggregateR2 %>% filter(!is.na(`Total Cost`)) # filter does not like NA's
AggregateR2a <- AggregateR2na %>%
  filter(between(`Total Cost`, quantile(`Total Cost`, 0.001), quantile(`Total Cost`, 0.95)),na.rm = TRUE)
histinfo<-hist(AggregateR2a$`Total Cost`)
histinfo

A602R2a <- A602R2 %>%
  filter(between(`Total Cost`, quantile(`Total Cost`, 0.001), quantile(`Total Cost`, 0.95)))
histinfo<-hist(A602R2a$`Total Cost`)
histinfo

A701R2a <- A701R2 %>%
  filter(between(`Total Cost`, quantile(`Total Cost`, 0.001), quantile(`Total Cost`, 0.95)))
histinfo<-hist(A701R2a$`Total Cost`)
histinfo

A123R2a <- A123R2 %>%
  filter(between(`Total Cost`, quantile(`Total Cost`, 0.001), quantile(`Total Cost`, 0.95)))
histinfo<-hist(A123R2a$`Total Cost`)
histinfo

A301R2a <- A301R2 %>%
  filter(between(`Total Cost`, quantile(`Total Cost`, 0.001), quantile(`Total Cost`, 0.95)))
histinfo<-hist(A301R2a$`Total Cost`)
histinfo




#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 2A  Use the requisition submitted date to calculate the number of submissions for each day of the year.

#-------------------------------------------------------------------------------
# 2A   Aggregate  

TotalCountbyDateAgg <- AggregateR2 %>%
  group_by(Day_Of_The_Year = (`Requisition submitted date`)) %>%
  summarise(Count_by_day = n_distinct(`Order #`), .groups = "drop")
TotalCountbyDate <- TotalCountbyDate[order(TotalCountbyDate$Day_Of_The_Year, decreasing = FALSE), ]
# Make Table #library("kableExtra")
TotalCountbyDateAgg %>%
  kbl() %>%
  kable_styling()
#-------------------------------------------------------------------------------
# 2A   602 

TotalCountbyDateA602 <- A602R2 %>%
  group_by(Day_Of_The_Year = (`Requisition submitted date`)) %>%
  summarise(Count_by_day = n_distinct(`Order #`), .groups = "drop")
TotalCountbyDateA602 <- TotalCountbyDate[order(TotalCountbyDate$Day_Of_The_Year, decreasing = FALSE), ]
# Make Table #library("kableExtra")
TotalCountbyDateA602 %>%
  kbl() %>%
  kable_styling()
#-------------------------------------------------------------------------------
# 2A   A701  

TotalCountbyDateA701 <- A701R2 %>%
  group_by(Day_Of_The_Year = (`Requisition submitted date`)) %>%
  summarise(Count_by_day = n_distinct(`Order #`), .groups = "drop")
TotalCountbyDateA701 <- TotalCountbyDate[order(TotalCountbyDate$Day_Of_The_Year, decreasing = FALSE), ]
# Make Table #library("kableExtra")
TotalCountbyDateA701 %>%
  kbl() %>%
  kable_styling()

#-------------------------------------------------------------------------------
# 2A   A123  

TotalCountbyDateA123 <- AggregateR2 %>%
  group_by(Day_Of_The_Year = (`Requisition submitted date`)) %>%
  summarise(Count_by_day = n_distinct(`Order #`), .groups = "drop")
TotalCountbyDateA123 <- TotalCountbyDate[order(TotalCountbyDate$Day_Of_The_Year, decreasing = FALSE), ]
# Make Table #library("kableExtra")
TotalCountbyDateA123 %>%
  kbl() %>%
  kable_styling()
#-------------------------------------------------------------------------------
# 2A   A601  

TotalCountbyDateA601 <- AggregateR2 %>%
  group_by(Day_Of_The_Year = (`Requisition submitted date`)) %>%
  summarise(Count_by_day = n_distinct(`Order #`), .groups = "drop")
TotalCountbyDateA601 <- TotalCountbyDate[order(TotalCountbyDate$Day_Of_The_Year, decreasing = FALSE), ]
# Make Table #library("kableExtra")
TotalCountbyDateA601 %>%
  kbl() %>%
  kable_styling()


#-------------------------------------------------------------------
#-------------------------------------------------------------------
# 2B  Create a boxplot of the number of submissions by the day of week.  
#      Do there appear to be differences by day of the week?

#-------------------------------------------------------------------------------
# 2B  
# Aggregate

eva_2018 <- VCU_Class_PO_fis18
#Rename fields
eva_2018 <- rename(eva_2018,Order="Order #")
eva_2018 <- rename(eva_2018,Req_Sub_Date="Requisition submitted date")
#Remove timestamps
eva_2018$Req_Sub_Date2<-substr(eva_2018$Req_Sub_Date,1,11)
#Apply Date format to field
date_columns <- c("Req_Sub_Date2")
eva_2018[date_columns] <- lapply(eva_2018[date_columns],
                                 strptime,
                                 format="%d-%b-%Y",
                                 tz="EST")
#Create DOW field
eva_2018$day <- weekdays(as.Date(eva_2018$Req_Sub_Date2))
#Count orders by REquisition submitted date
(RecieveCount<- eva_2018%>%
    dplyr::group_by(Req_Sub_Date2,day) %>%
    dplyr::select(Req_Sub_Date2,day,Order) %>%
    dplyr::summarize (n_distinct(Order),.groups='drop'))
#Figured out how to order the DOW before plotting
RecieveCount$day <- factor(RecieveCount$day , levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                       "Friday","Saturday","Sunday"))
#Create box plots for all DOW side by side
boxplot(`n_distinct(Order)`~day,
        data=RecieveCount,
        main="Aggregate: Different boxplots for each day of week",
        xlab="Day of Week",
        ylab="Count of Submissions",
        col="green",
        border="black")

#-------------------------------------------------------------------------------
# A602

eva_2018 <- A602R2
#Rename fields
eva_2018 <- rename(eva_2018,Order="Order #")
eva_2018 <- rename(eva_2018,Req_Sub_Date="Requisition submitted date")
#Remove timestamps
eva_2018$Req_Sub_Date2<-substr(eva_2018$Req_Sub_Date,1,11)
#Apply Date format to field
date_columns <- c("Req_Sub_Date2")
eva_2018[date_columns] <- lapply(eva_2018[date_columns],
                                 strptime,
                                 format="%d-%b-%Y",
                                 tz="EST")
#Create DOW field
eva_2018$day <- weekdays(as.Date(eva_2018$Req_Sub_Date2))
#Count orders by REquisition submitted date
(RecieveCount<- eva_2018%>%
    dplyr::group_by(Req_Sub_Date2,day) %>%
    dplyr::select(Req_Sub_Date2,day,Order) %>%
    dplyr::summarize (n_distinct(Order),.groups='drop'))
#Figured out how to order the DOW before plotting
RecieveCount$day <- factor(RecieveCount$day , levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                       "Friday","Saturday","Sunday"))
#Create box plots for all DOW side by side
boxplot(`n_distinct(Order)`~day,
        data=RecieveCount,
        main="A602 Different boxplots for each day of week",
        xlab="Day of Week",
        ylab="Count of Submissions",
        col="green",
        border="black")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# A123

eva_2018 <- A123R2
#Rename fields
eva_2018 <- rename(eva_2018,Order="Order #")
eva_2018 <- rename(eva_2018,Req_Sub_Date="Requisition submitted date")
#Remove timestamps
eva_2018$Req_Sub_Date2<-substr(eva_2018$Req_Sub_Date,1,11)
#Apply Date format to field
date_columns <- c("Req_Sub_Date2")
eva_2018[date_columns] <- lapply(eva_2018[date_columns],
                                 strptime,
                                 format="%d-%b-%Y",
                                 tz="EST")
#Create DOW field
eva_2018$day <- weekdays(as.Date(eva_2018$Req_Sub_Date2))
#Count orders by REquisition submitted date
(RecieveCount<- eva_2018%>%
    dplyr::group_by(Req_Sub_Date2,day) %>%
    dplyr::select(Req_Sub_Date2,day,Order) %>%
    dplyr::summarize (n_distinct(Order),.groups='drop'))
#Figured out how to order the DOW before plotting
RecieveCount$day <- factor(RecieveCount$day , levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                       "Friday","Saturday","Sunday"))
#Create box plots for all DOW side by side
boxplot(`n_distinct(Order)`~day,
        data=RecieveCount,
        main="A123 Different boxplots for each day of week",
        xlab="Day of Week",
        ylab="Count of Submissions",
        col="green",
        border="black")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# A301

eva_2018 <- A301R2
#Rename fields
eva_2018 <- rename(eva_2018,Order="Order #")
eva_2018 <- rename(eva_2018,Req_Sub_Date="Requisition submitted date")
#Remove timestamps
eva_2018$Req_Sub_Date2<-substr(eva_2018$Req_Sub_Date,1,11)
#Apply Date format to field
date_columns <- c("Req_Sub_Date2")
eva_2018[date_columns] <- lapply(eva_2018[date_columns],
                                 strptime,
                                 format="%d-%b-%Y",
                                 tz="EST")
#Create DOW field
eva_2018$day <- weekdays(as.Date(eva_2018$Req_Sub_Date2))
#Count orders by REquisition submitted date
(RecieveCount<- eva_2018%>%
    dplyr::group_by(Req_Sub_Date2,day) %>%
    dplyr::select(Req_Sub_Date2,day,Order) %>%
    dplyr::summarize (n_distinct(Order),.groups='drop'))
#Figured out how to order the DOW before plotting
RecieveCount$day <- factor(RecieveCount$day , levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                       "Friday","Saturday","Sunday"))
#Create box plots for all DOW side by side
boxplot(`n_distinct(Order)`~day,
        data=RecieveCount,
        main="A301 Different boxplots for each day of week",
        xlab="Day of Week",
        ylab="Count of Submissions",
        col="green",
        border="black")









#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#3. Again using the requisition submitted date, calculate the number of submissions for each month.  
# Use the result to create a line plot with the number of submissions on the y-axis and the month on the x-axis.  
# Include a line for each group member's agency.  Do any of the group's agencies exhibit seasonality in submissions?  

PO18 <- VCU_Class_PO_fis18

#----------------------------------------------------------------
#Change fields with Dates from Character fields to Date Fields

#PO change format of a single date column (character format:DD-MM-YYYY 00:00:00) from character to date (YYYY-MM-DD)
# using library(lubridate)
PO18$`Requisition submitted date` <- as.Date(dmy_hms(PO18$`Requisition submitted date`))
PO18$`Requisition Approved Date` <- as.Date(dmy_hms(PO18$`Requisition Approved Date`))
PO18$`ORDERDATE` <- as.Date(dmy_hms(PO18$`ORDERDATE`))

AggregateR2 <- PO18
AggR2 <- PO18
A602R2 <- PO18%>% filter(str_detect(`Entity Code`, "A602"))
A701R2 <- PO18%>% filter(str_detect(`Entity Code`, "A701"))
A123R2 <- PO18%>% filter(str_detect(`Entity Code`, "A123"))
A301R2 <- PO18%>% filter(str_detect(`Entity Code`, "A301"))

#-------------------------------------------------------------------------------
# 3   Aggregate
TotalCountbyMonthsAgg <- AggregateR2  %>%
  filter(!is.na(`Requisition submitted date`)) %>%
  group_by(Months_of_Year = months(as.Date(`Requisition submitted date`))) %>%
  summarise(Count_by_month = n_distinct(`Order #`), .groups = "drop")

TotalCountbyMonthsAgg <- TotalCountbyMonthsAgg %>% arrange(match(Months_of_Year, month.name))
TotalCountbyMonthsAgg

TotalCountbyMonthsAgg$Months_of_Year_factor <- factor(TotalCountbyMonthsAgg$Months_of_Year, levels = TotalCountbyMonthsAgg$Months_of_Year)

ggplot(data=TotalCountbyMonthsAgg, aes(x =Months_of_Year_factor, y=Count_by_month, group=1)) +
  geom_line()+
  geom_point()+
  xlab("Aggregate")



#-------------------------------------------------------------------------------
# 3   A602
TotalCountbyMonthsA602 <- A602R2  %>%
  filter(!is.na(`Requisition submitted date`)) %>%
  group_by(Months_of_Year = months(as.Date(`Requisition submitted date`))) %>%
  summarise(Count_by_month = n_distinct(`Order #`), .groups = "drop")

TotalCountbyMonthsA602 <- TotalCountbyMonthsA602 %>% arrange(match(Months_of_Year, month.name))
TotalCountbyMonthsA602

TotalCountbyMonthsA602$Months_of_Year_factor <- factor(TotalCountbyMonthsA602$Months_of_Year, levels = TotalCountbyMonthsA602$Months_of_Year)

ggplot(data=TotalCountbyMonthsA602, aes(x =Months_of_Year_factor, y=Count_by_month, group=1)) +
  geom_line()+
  geom_point()+
  xlab("A602")


#-------------------------------------------------------------------------------
# 3   A701
TotalCountbyMonthsA701 <- A701R2  %>%
  filter(!is.na(`Requisition submitted date`)) %>%
  group_by(Months_of_Year = months(as.Date(`Requisition submitted date`))) %>%
  summarise(Count_by_month = n_distinct(`Order #`), .groups = "drop")

TotalCountbyMonthsA701 <- TotalCountbyMonthsA701 %>% arrange(match(Months_of_Year, month.name))
TotalCountbyMonthsA701

TotalCountbyMonthsA701$Months_of_Year_factor <- factor(TotalCountbyMonthsA701$Months_of_Year, levels = TotalCountbyMonthsA701$Months_of_Year)

ggplot(data=TotalCountbyMonthsA701, aes(x =Months_of_Year_factor, y=Count_by_month, group=1)) +
  geom_line()+
  geom_point()+
  xlab("A701")


#-------------------------------------------------------------------------------
# 3   A123
TotalCountbyMonthsA123 <- A123R2  %>%
  filter(!is.na(`Requisition submitted date`)) %>%
  group_by(Months_of_Year = months(as.Date(`Requisition submitted date`))) %>%
  summarise(Count_by_month = n_distinct(`Order #`), .groups = "drop")

TotalCountbyMonthsA123 <- TotalCountbyMonthsA123 %>% arrange(match(Months_of_Year, month.name))
TotalCountbyMonthsA123

TotalCountbyMonthsA123$Months_of_Year_factor <- factor(TotalCountbyMonthsA123$Months_of_Year, levels = TotalCountbyMonthsA123$Months_of_Year)

ggplot(data=TotalCountbyMonthsA123, aes(x =Months_of_Year_factor, y=Count_by_month, group=1)) +
  geom_line()+
  geom_point()+
  xlab("A123")



#-------------------------------------------------------------------------------
# 3   A301
TotalCountbyMonthsA301 <- A301R2  %>%
  filter(!is.na(`Requisition submitted date`)) %>%
  group_by(Months_of_Year = months(as.Date(`Requisition submitted date`))) %>%
  summarise(Count_by_month = n_distinct(`Order #`), .groups = "drop")

TotalCountbyMonthsA301 <- TotalCountbyMonthsA301 %>% arrange(match(Months_of_Year, month.name))
TotalCountbyMonthsA301

TotalCountbyMonthsA301$Months_of_Year_factor <- factor(TotalCountbyMonthsA301$Months_of_Year, levels = TotalCountbyMonthsA301$Months_of_Year)

ggplot(data=TotalCountbyMonthsA301, aes(x =Months_of_Year_factor, y=Count_by_month, group=1)) +
  geom_line()+
  geom_point()+
  xlab("A301")


#--------------------------------------------------------------
TableTest4 <-cbind(TotalCountbyMonthsAgg[ ,3],
                   TotalCountbyMonthsAgg[ ,2],
                   TotalCountbyMonthsA602[ ,2],
                   TotalCountbyMonthsA701[ ,2],
                   TotalCountbyMonthsA123[ ,2],
                   TotalCountbyMonthsA301 [ ,2])

colnames(TableTest4) = c("Months_of_Year", "Agg", "A602", "A701", "A123", "A301" )

for_plot_df <- reshape2::melt(TableTest4)
head(for_plot_df)

#Plot including AggregateQ
ggplot(for_plot_df, aes(x=Months_of_Year, y= value , group= variable)) + 
  geom_line(aes(color=variable)) 

#Plot not including Aggregate
for_plot_df2 <- for_plot_df[for_plot_df$variable != "Agg", ]
ggplot(for_plot_df2, aes(x=Months_of_Year, y= value , group= variable)) + 
  geom_line(aes(color=variable)) 


