#Generalized Linear Models

#Lumber Example (Poisson Regression)

#Read in data
lumber <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 622/lumber.txt",sep=",",header=TRUE)

#Poisson Regression
mymodel <- glm(Number.of.Customers ~ Housing.Units + Average.Income + 
                 Average.Age + Competitor.Distance + Store.Distance,family="poisson",data=lumber)

summary(mymodel)

#Check for overdispersion
disperse <- glm(Number.of.Customers ~ Housing.Units + Average.Income + 
                  Average.Age + Competitor.Distance + Store.Distance,family="quasipoisson",
                  data=lumber)
summary(disperse)

#Overall model test (Deviance Test: higher values of deviance indicate a worse fit)
#Null hypothesis: Model is correctly specified
pchisq(mymodel$deviance,df=mymodel$df.residual,lower.tail=FALSE)

#Effect Tests
library(car)
Anova(mymodel,type=3)

#Diagnostics
plot(mymodel)

#############################################################
#Lung Data Example
lung <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 622/lung.txt",sep=",",header=TRUE)

#Poisson Regression
mymodel <- glm(cases ~ city + age, offset=log(pop),family="poisson",data=lung)

summary(mymodel)

#Check for overdispersion
disperse <- glm(cases ~ city + age,offset=log(pop), family="quasipoisson", data=lung)
summary(disperse)

#Overdispersion test
pchisq(summary(disperse)$dispersion*mymodel$df.residual,mymodel$df.residual,lower=FALSE)

#Overall model test (Deviance Test: higher values of deviance indicate a worse fit)
#Null hypothesis: Model is correctly specified
pchisq(mymodel$deviance,df=mymodel$df.residual,lower.tail=FALSE)

#Effect Tests
library(car)
Anova(mymodel,type=3)

#Diagnostics
plot(mymodel)
