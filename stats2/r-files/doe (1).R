#Battery Brands Data
battery <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 622/R files/BatteryBrands.txt",sep=',',header=TRUE)

#Fit ANOVA model
mod <- aov(Life ~ as.factor(Brand), data=battery)
summary(mod)

#Check assumpiton of  constant variance
plot(mod,which=1)

#Check assumption of normality of residuals
plot(mod, which=2)

#Perform a Tukey test for all pairwise comoparisons
mod.Tukey <- TukeyHSD(mod)
mod.Tukey

##############################

#Multi-factor factorial 
#A company whose sales are made online through a Web page would like to increase the proportion of visitors to their Web site that sign up for their service by optimally
#configuring their Web page. In  order to buy from the company, customers must signup and fill out a form supplying  their email address along with other required fields. 
#Once a customer signs up, the company has contact information for their database and can email advertisements, special offers, etc. 

#The company would like to experiment by testing different configurations of their Web page to see if they can increase the number of vistors to their site that actually
#sign up. 

#The experimental units in this  study will be individuals who visit the company Web site. The response is binary; the customer either signs up or doesn't. The factors
#under study were characteristics that change the appearance of the Web page. 

#Factor A: background alternative (3 levels)
#Factor B: font size for main banner (3 levels)
#Factor C: text color (2 levels)
#Factor D: sign-up button or link (2 levels)

#3 x 3 x 2 x2 = 36 possible combinations

library(daewr)
data(web)
web

modweb <- glm(cbind(signup,visitors-signup)~A*B*C*D,data=web,family=binomial)
anova(update(modweb,.~A+B +A:B + C + A:C + B:C + A:B:C + D + A:D + B:D + A:B:D + C:D + A:C:D + B:C:D + A:B:C:D),test="Chisq")

#interaction plots
prop <- web$signup / web$visitors
webp <- data.frame(web,prop)
par(mfrow=c(1,3))
webp1 <- subset(webp,A==1)
interaction.plot(webp1$C,webp1$D,webp1$prop,type="l",legend=FALSE,main="Background=1",ylim=c(0.015,0.0275), xlab="Text Color",ylab="Proportion Signing Up")

webp2 <- subset(webp,A==2)
interaction.plot(webp2$C,webp2$D,webp2$prop,type="l",legend=FALSE,main="Background=2",ylim=c(0.015,0.0275),xlab="Text Color",ylab=" ")
lines(c(1.7,1.85),c(0.016,0.016),lty=2)
lines(c(1.7,1.85),c(0.017,0.017),lty=1)
text(1.3,0.017,"Sign-up link")
text(1.3,0.016,"Sign-up button")

webp3 <- subset(webp,A==3)
interaction.plot(webp3$C,webp3$D,webp3$prop,type="l",legend=FALSE,ylim=c(0.015,0.0275), main="Background=3",xlab="Text Color",ylab=" ")


###################################################################################################

#Two-Level Design
BHH <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 622/R files/BHH.txt",sep=',',header=TRUE)
BHHmod <- lm(Y~Catalyst.Charge*Temperature*Pressure*Concentration,data=BHH)
summary(BHHmod)

#Half normmal plot
library(daewr)
par(mfrow=c(1,1))
LGB(coef(BHHmod)[-1],rpt=FALSE)

#Fit reduced model
BHHmod.Reduced <- lm(Y~Temperature + Catalyst.Charge + Concentration + Temperature:Concentration + Pressure,data=BHH)
summary(BHHmod.Reduced)

#Check Assumptions
plot(BHHmod.Reduced,which=1)
plot(BHHmod.Reduced,which=2)

#Interaction plot
interaction.plot(BHH$Temperature,BHH$Concentration,BHH$Y,type="b",pch=c(18,24))


###################################################################################################

#Fractional Factorial Design
marketing <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 622/R files/MarketingDOE.txt",sep=',',header=TRUE)
marketing <- marketing[,-20]
FFmod <- lm(Response.Rate~.,data=marketing)

#normal plot 
fullnormal(coef(FFmod)[-1],alpha=0.025)

#reduced model
marketing.Reduced <- lm(Response.Rate~Interest.Rate*Sticker,data=marketing)
summary(marketing.Reduced)

#Interaction plot
interaction.plot(marketing$Interest.Rate,marketing$Sticker,marketing$Response.Rate,type="b",pch=c(18,24))



