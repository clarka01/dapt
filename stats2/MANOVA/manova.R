#Read in HBAT data
HBAT <- read.table("C:/Users/dedwa/Desktop/Teaching/DAPT 622/R files/HBAT.txt",sep=",",header=TRUE)

#MANOVA test for Distribution System
myMANOVA <- manova(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~X5...Distribution.System,data=HBAT)
summary(myMANOVA, test="Pillai")
summary(myMANOVA, test="Wilks")
summary(myMANOVA, test="Hotelling-Lawley")
summary(myMANOVA, test="Roy")

summary.aov(myMANOVA)

#Visualize Differences
boxplot(X19...Satisfaction~X5...Distribution.System,data=HBAT,ylab="Satisfaction")
boxplot(X20...Likely.to.Recommend~X5...Distribution.System,data=HBAT,ylab="Likely to Recommend")
boxplot(X21...Likely.to.Purchase~X5...Distribution.System,data=HBAT,ylab="Likely to Purchase")

#MANOVA test for Customer Type
myMANOVA <- manova(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~X1...Customer.Type,data=HBAT)
summary(myMANOVA, test="Pillai")
summary(myMANOVA, test="Wilks")
summary(myMANOVA, test="Hotelling-Lawley")
summary(myMANOVA, test="Roy")

summary.aov(myMANOVA)

#Tukey test for each response
TukeyHSD(aov(X19...Satisfaction~X1...Customer.Type,data=HBAT))
boxplot(X19...Satisfaction~X1...Customer.Type,data=HBAT,ylab="Satisfaction")

TukeyHSD(aov(X20...Likely.to.Recommend~X1...Customer.Type,data=HBAT))
boxplot(X20...Likely.to.Recommend~X1...Customer.Type,data=HBAT,ylab="Likely to Recommend")

TukeyHSD(aov(X21...Likely.to.Purchase~X1...Customer.Type,data=HBAT))
boxplot(X21...Likely.to.Purchase~X1...Customer.Type,data=HBAT,ylab="Likely to Purchase")

##################################
#Two-way MANOVA
#MANOVA test for Distribution System
myMANOVA <- manova(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~X1...Customer.Type*X5...Distribution.System,data=HBAT)
summary(myMANOVA, test="Pillai")
summary(myMANOVA, test="Wilks")
summary(myMANOVA, test="Hotelling-Lawley")
summary(myMANOVA, test="Roy")

summary.aov(myMANOVA)

#Interaction plots
interaction.plot(HBAT$X5...Distribution.System,HBAT$X1...Customer.Type,HBAT$X19...Satisfaction,type="b",ylab="Satisfaction")
interaction.plot(HBAT$X5...Distribution.System,HBAT$X1...Customer.Type,HBAT$X20...Likely.to.Recommend,type="b",ylab="Recommend")
interaction.plot(HBAT$X5...Distribution.System,HBAT$X1...Customer.Type,HBAT$X21...Likely.to.Purchase,type="b",ylab="Purchase")

########################################################################################
#Multivariate Regression

HBATreduced <- HBAT[,-which(names(HBAT) %in% c("ID","X22...Purchase.Level","X23...Consider.Strategic.Alliance"))]
model <- manova(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~.,data=HBATreduced)
summary(model)

#What's wrong here? Can you tell based on degrees of freedom? 
library(dplyr)
HBATreduced <- HBATreduced %>%
                  filter(X6...Product.Quality!="Excellent") %>%
                  filter(X13...Competitive.Pricing!="Excellent")

HBATreduced$X6...Product.Quality <- as.numeric(as.character(HBATreduced$X6...Product.Quality))
HBATreduced$X13...Competitive.Pricing <- as.numeric(as.character(HBATreduced$X13...Competitive.Pricing))

model <- manova(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~.,data=HBATreduced)
summary(model)

summary.aov(model)

HBATreg <- HBATreduced[,-which(names(HBATreduced) %in% c("X14...Warranty...Claims","X15...New.Products","X16...Order...Billing","X17...Price.Flexibility","X18...Delivery.Speed"))]
regmodel <- lm(cbind(X19...Satisfaction,X20...Likely.to.Recommend,X21...Likely.to.Purchase)~.,data=HBATreg)
