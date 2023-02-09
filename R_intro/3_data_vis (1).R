library(ggplot2)
library(reshape2)
library(rgl)
library(dplyr)


senic_data <- read.table("SENIC.csv", header=TRUE, row.names=1, sep=",",
                        colClasses=c(rep("numeric",7),rep("factor",2),
                        rep("numeric",9), rep("factor",2)))
senic_data <- senic_data[,-ncol(senic_data)]

load("eva_2019.rda")


hist(senic_data$Culture_ratio)


hist(senic_data$Culture_ratio, col="red",border="blue", 
     xlab="Culture Ratio", main="Histogram of Culture Ratio") 


dev.off()


pdf("culture_hist.pdf")
hist(senic_data$Culture_ratio, col="red", border="blue", 
     xlab="Culture Ratio", main="Histogram of Culture Ratio") 
dev.off()


png("culture_hist.png")
hist(senic_data$Culture_ratio, col="red", border="blue", 
     xlab="Culture Ratio", main="Histogram of Culture Ratio") 
dev.off()


log_culture_ratio <- log(senic_data$Culture_ratio)
hist(log_culture_ratio)


normalized_log_culture_ratio <- scale(log_culture_ratio)
hist(normalized_log_culture_ratio)


ggplot(senic_data, aes(x=Culture_ratio)) + 
    geom_histogram()


region_counts <- table(senic_data$Region_Name)
barplot(region_counts)


boxplot(senic_data$Length_stay ~ senic_data$Region_Name)


med_school_region_table <- table(senic_data$Region_Name, senic_data$Medical_School)
mosaicplot(med_school_region_table, color=c(1:2), xlab="Region",
           ylab="Medical School",main="")


plot(x=senic_data$Age_years, y=senic_data$Length_stay, 
     xlab="Average Age", ylab="Average Length of Stay", 
     main="Plot of Average Length of Stay versus Average Age",
     col=as.numeric(senic_data$Medical_School),
     pch=as.numeric(senic_data$Medical_School))
legend("topleft", title="Med School Affiliation?", legend=c("No", "Yes"), 
       col=1:nlevels(senic_data$Medical_School),
       pch=1:nlevels(senic_data$Medical_School)) 


plot3d(senic_data$Length_stay, senic_data$Age_years, senic_data$Infection_pct, 
       col=as.numeric(senic_data$Region_Name), type="s", 
       xlab="Average Length of Stay",ylab="Average Age", 
       zlab="Average Prob. of Infection")
legend3d("topright", levels(senic_data$Region_Name), 
         col=1:nlevels(senic_data$Region_Name), pch=16)


