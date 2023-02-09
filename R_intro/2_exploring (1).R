library(dplyr)
library(reshape2)

adult_data <- read.table("adult_data.csv", header=TRUE, sep=",",
                       colClasses = c("numeric", "factor",
                      "numeric", "factor", "numeric", rep("factor",5),
                      rep("numeric",3), rep("factor",2)), na.strings=" ?")


load("eva_2019.rda")


adult_data[2,3]


adult_data$occupation
adult_data[,7]
adult_data[,c("occupation")]
adult_data[,grep("occupation", names(adult_data))]


adult_data %>% dplyr::select(occupation)
adult_data %>% dplyr::select(7)


capital_gains_k <- adult_data$capital.gain/1000
capital_gains_k[1:100]


adult_data[,c(1,7)]
adult_data[,c("Age", "occupation")]
adult_data %>% dplyr::select(Age, occupation)
adult_data %>% dplyr::select(1, 7)


masters_data <- adult_data[adult_data[,4] == " Masters",]


masters_data <- adult_data %>%
  dplyr::filter(education == " Masters")


summary(adult_data$education)
adult_data$education <- factor(adult_data$education, levels =c(
  " Preschool",  " 1st-4th",  " 5th-6th",  " 7th-8th",  " 9th",  " 10th",  " 11th", 
  " 12th",  " HS-grad",  " Some-college", " Assoc-voc", " Assoc-acdm",
  " Bachelors", " Masters", " Prof-school", " Doctorate"))


head(adult_data[order(adult_data$hours.wk, adult_data$capital.gain, decreasing=TRUE),])


adult_data %>%
  dplyr::arrange(desc(hours.wk), desc(capital.gain)) %>%
  head()


dim(adult_data)
nrow(adult_data)
ncol(adult_data)

summary(adult_data$education)


(my_summary <- summary(adult_data))


occupation_missing <- is.na(adult_data$occupation)
occupation_missing[1:10]


apply(is.na(adult_data),2,sum)


sum(is.na(adult_data))


table(adult_data$native.country, adult_data$sex)


(avg_capital_gains <- adult_data %>%
                      dplyr::group_by(education, marital.status) %>%
                      dplyr::select(education, marital.status, capital.gain) %>%
                      dplyr::summarize(mean(capital.gain),
                                .groups='drop'))


(avg_capital_gains_table <- dcast(avg_capital_gains,education ~ marital.status, 
                              value.var="mean(capital.gain)"))


(my_melted_table <- melt(avg_capital_gains_table, id.vars = "education", 
                      measure.vars=c(" Divorced"," Married-AF-spouse",
                                     " Married-civ-spouse"," Married-spouse-absent", 
                                     " Never-married", " Separated", " Widowed")))


