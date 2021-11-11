
#install.packages("forecast")
#install.packages("ggfortify")
#install.packages("carData")
install.packages("VDA")

library(fpp3)
library(dplyr)
library(pander)
library(ggthemes)
library(purrr)
library(ggsci)
library(ggplot2)
library(readr)
library(forecast)
library(fable)
options(scipen = 1000)
library(leaps)
library(MASS)
library(ggfortify)
library(corrplot)
library(carData)
library(car)
library(mdsr)
library(ape)

# set pander table-layout options --------
panderOptions('table.alignment.default', function(df)
  ifelse(sapply(df, is.numeric), 'right', 'left'))
panderOptions('table.split.table', Inf)

# import the file
downtime_lease <- read_csv("/Users/baxna/Documents/DAPT/Costar Practicum/CoStar Data/downtime_lease_nov8.csv")

#Drop the first column
downtime_lease <- subset (downtime_lease, select = -X1)

lapply(downtime_lease,class)

# install.packages("fitdistrplus")

library(fitdistrplus)

months <- downtime_lease %>%
  dplyr::filter(vacant_months > 0)

fitw <- fitdist(months$vacant_months, "weibull")
fitlnorm <- fitdist(months$vacant_months, "lnorm")
#fitbeta <- fitdist(days$days_on_market, "beta") #Beta distributions are for values b/w 0 and 1
fitgamma <- fitdist(months$vacant_months, "gamma")
fitnorm <- fitdist(months$vacant_months, "norm")
fitnbiom <- fitdist(months$vacant_months, "nbinom")
fitlogis <- fitdist(months$vacant_months, "logis")
#fitpois <- fitdist(months$vacant_months, "pois") # not a good fit

denscomp(list(fitw, fitlnorm, fitgamma))

summary(fitw)
summary(fitlnorm) #best fitting
summary(fitgamma) #second best fitting
summary(fitnorm)
summary(fitnbiom)
#summary(fitlogis)
#summary(fitpois)

lapply(downtime_lease,class)

#create df with only numeric columns
#Removed actual_esti_rent_ration, service_type_id,property_type_id, tenant_improvement_allowance_persqft
#and free_months because the standard deviation was 0. Try making them characters.
downtime_lease_sub <- downtime_lease[,c("property_id","vacant_months","location_occupancy_id",
                                        "building_rating_id","cbsaid")]

#Get variance-covariance matrix
#need to look up the meaning of this
covmat <- cov(downtime_lease_sub)
covmat

#Get correlation matrix
corrmat <- cor(downtime_lease_sub)
corrmat
corrplot(corrmat,method="color")
#of the x variables property_id and building _rating_id have the strongest correlation (r=-0.29)
#which happens to be negative.  This is good that the variables are not correlated.

# Graphical Assessment of Multivariate Normality
x <- as.matrix(downtime_lease_sub) # n x p numeric matrix
center <- colMeans(x) # centroid
n <- nrow(x); 
p <- ncol(x); 
cov <- cov(x); 
d <- mahalanobis(x,center,cov) # distances 
qqplot(qchisq(ppoints(n),df=p),d,
       main="QQ Plot Assessing Multivariate Normality",
       ylab="Mahalanobis D2")
abline(a=0,b=1)

#Get scatterplot matrix (takes a really long time to run and not very interesting)
#pictoraly shows the same info as the correlation matrix
#pairs(~lease_term_in_months+actual_esti_rent_ratio+free_months
#      +building_rating_id+cbsaid+vacant_months+tenant_improvement_allowance_persqft,
#      data=downtime_lease)

fit <- lm(log(vacant_months)~ tenant_improvement_allowance_persqft + free_months + 
          building_rating_id, data=downtime_lease)
summary(fit)
autoplot(fit)

plot(fitted(fit),residuals(fit))


#to determine if multicollinearity exists.  Value of 1 indicates no correlation b/w variables
##Value b/w 1 & 5 indicates moderate correlation.  Value > 5 indicates potentially severe correlation
#https://www.statology.org/variance-inflation-factor-r/
vif(fit) #Variance inflation factor- all variables slightly above 1
#Multicollinearity does not exist, so lasso is not necessary.
#https://www.statology.org/lasso-regression-in-r/
autoplot(fit)

fit1 <- lm(vacant_months~ property_id + location_occupancy_id + 
            building_rating_id + cbsaid, data=downtime_lease)
summary(fit1)
autoplot(fit1)

fit2 <- lm(vacant_months~ cbsaid, data=downtime_lease)
summary(fit2)
autoplot(fit2)

fit3 <- lm(log(vacant_months)~ cbsaid, data=downtime_lease)
summary(fit3)
autoplot(fit3)

fit4 <- lm(log(vacant_months)~ building_rating_id, data=downtime_lease)
summary(fit4)
autoplot(fit4)

#----------------------------------------------------------------------------

#Run Stepwise Regression
#null <- lm(log(vacant_months) ~ 1,data=downtime_lease)
#full <- lm(log(vacant_months) ~ ., data=downtime_lease)

#forward <- step(null,scope=list(lower=null,upper=full),direction="forward")
#summary(forward)

#backward <- step(full,direction="backward")
#summary(backward)

#both <- step(null,scope=list(upper=full),direction="both")
#summary(both)

#Run All-Subsets Regression
#allsubs <- regsubsets(days_on_market ~ . , nbest=10, data=downtime_lease)
#summary(allsubs)
#plot(allsubs,scale="r2")

#Run LASSO
library(glmnet)
#define the response variable
y <- downtime_lease1$vacant_months

sum(is.na(downtime_lease$property_id))
sum(is.na(downtime_lease$vacant_months))
sum(is.na(downtime_lease$location_occupancy_id))
sum(is.na(downtime_lease$building_rating_id))
sum(is.na(downtime_lease$cbsaid))
sum(is.na(downtime_lease$estimated_rent))
sum(is.na(downtime_lease$service_type_id))

downtime_lease1 <- downtime_lease %>%
  dplyr::filter(estimated_rent > 0)

#glmnet can't handle N/As. Removed TI, Free Months & service_type_id from x
#define the matrix of predictor variables
x <- data.matrix(downtime_lease1, c('property_id','vacant_months','location_occupancy_id',
                                   'building_rating_id','cbsaid','estimated_rent'
                                   ))
#Haven't been able to get this to work!!!
#k-fold cross validation to determine value for lambda that produces lowest MSE
cv_model <- cv.glmnet(x, y, alpha = 1)

# lambda vector
lam.vec <- (1:10)/10

# searching for the best lambda with 10-fold cross validation and plot cv
cv <- cv.vda.r(x, y, 10, lam.vec)



x <- x[,-1]
lasso <- glmnet(x=x, y=y [,3])
plot(lasso)
coef(lasso)

# we could do a lasso on this
# then fit lm
# leverage plots -- look for non-linear behavior
# test and train

