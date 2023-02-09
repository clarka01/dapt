library(faraway)
library(ggplot2)
library(lme4)
library(lmerTest)

data(pulp)

#Simple 1-way ANOVA
model <- aov(bright~operator,data=pulp)
summary(model)

ggplot(pulp,aes(x=operator,y=bright)) + geom_point()

#Fit a mixed model
mmod <- lmer(bright ~ 1 + (1|operator),data=pulp)
summary(mmod)

#Predictions for random effects
ranef(mmod)

#Model diagnostics
qqnorm(residuals(mmod))
plot(fitted(mmod),residuals(mmod),xlab="Predicted",ylab="Residuals")

##################################################################################
#School Data Set
scoreData <- read.table("C:/Users/dedwards7/Desktop/data6e/school23.txt",header=TRUE,
                        colClasses = c(rep("factor",6),"numeric", "factor", "numeric", rep("factor",6)))

#Usual linear model
reg <- lm(MATH~SCHTYPE+SES+SCHOOL,data=scoreData)
summary(reg)

#Mixed model treating school as a random effect
mixed1 <- lmer(MATH~SCHTYPE + SES + (1|SCHOOL),data=scoreData)
summary(mixed1)

#Mixed model that includes a random intercept and SES slope for each school
mixed2 <- lmer(MATH ~ SCHTYPE + SES + (SES|SCHOOL), data=scoreData)
summary(mixed2)

ranef(mixed2)
qqnorm(residuals(mixed2))
plot(fitted(mixed2),residuals(mixed2))

#Mixed model that includes random intercepts and slopes for SEX and SES
mixed3 <- lmer(MATH~SCHTYPE + SES + SEX + (SES|SCHOOL) + (SEX|SCHOOL),data=scoreData)
summary(mixed3)

ranef(mixed3)
qqnorm(residuals(mixed3))
plot(fitted(mixed3),residuals(mixed3))

###############################################################################
#Longitudinal Data
library(dplyr)
data(psid)

#Visualizations
psid20 <- psid %>%
            filter(person <= 20)
ggplot(psid20, aes(x=year, y=income)) + geom_line() + facet_wrap(~person)
ggplot(psid20, aes(x=year, y=income, group=person)) + geom_line() + facet_wrap(~sex)

#center the year predictor at the median 
psid$cyear <- psid$year - 78
mmod <- lmer(log(income) ~ cyear*sex + age + educ + (cyear|person), data=psid)
summary(mmod)

ranef(mmod)
qqnorm(residuals(mmod)) #Should consider changing the log transformation on the response
plot(fitted(mmod),residuals(mmod))

#############################################################################
#Repeated Measures with Nesting
data(vision)
vision$npower <- rep(1:4,14)
ggplot(vision, aes(y=acuity,x=npower, linetype=eye)) + geom_line() + facet_wrap(~subject,ncol=4)

mmod <- lmer(acuity ~ power + (1|subject) + (1|subject:eye),data=vision)
summary(mmod)
anova(mmod)

qqnorm(residuals(mmod))
plot(fitted(mmod),residuals(mmod))
