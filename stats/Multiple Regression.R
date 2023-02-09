#Regression Analysis with R

#Home Data Revisited
#install.packages("xlsx")
#Read in data
home.data <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 621/HomeData.txt",sep="\t",comment.char = "", header=TRUE, 
                        stringsAsFactors = FALSE)

#Plot data/Check for outliers
class(home.data$Price)
class(home.data$Sq_Ft)
home.data$Price <- gsub(",","",home.data$Price)
home.data$Price <- gsub("\\$", "", home.data$Price)
home.data$Price <- as.numeric(home.data$Price)
home.data$Sq_Ft <- gsub(",","",home.data$Sq_Ft)
home.data$Sq_Ft <- as.numeric(home.data$Sq_Ft)

pairs(home.data[,c("Price","Sq_Ft","Bedrooms","Baths")])

home.data <- home.data[-which(home.data$Price > 4000000),]
pairs(home.data[,c("Price","Sq_Ft","Bedrooms","Baths")])

#Fit a model for predicting price based on square feet, bedrooms, and bathrooms
fit <- lm(Price ~ Sq_Ft+ Bedrooms + Baths, data=home.data)
summary(fit)

#Residual diagnostics
plot(fit)

#Get ANOVA table
anova(fit)

#95% confidence intervals for regression coefficients
confint(fit)

#Get predictions and intervals related to prediction
predict(fit)
predict(fit,interval='confidence')
predict(fit,interval='prediction')
predict(fit,newdata=list(Sq_Ft=2500, Bedrooms=4, Baths=2.5),interval='prediction')

#Compare two models
#Do we need the extra information provided by number of bedrooms and bathrooms in the model? 
fit2 <- lm(Price ~ Sq_Ft,data=home.data)
anova(fit,fit2)


###########################################################################################################
# Adding Categorical/Dummy Variables
#Plot data
library(ggplot2)
ggplot(home.data,aes(x=Sq_Ft,y=Price,colour=factor(Location))) + geom_point() + 
  geom_smooth(method="lm", se=FALSE)

#Fit a model for predicting price based on square feet and location
fit1 <- lm(Price ~ Sq_Ft + Location, data=home.data)
summary(fit1)

#Change the reference level to match JMP's default
home.data$Location <- relevel(home.data$Location, ref="Richmond")
fit1 <- lm(Price ~ Sq_Ft + Location, data=home.data)
summary(fit1)


#Fit a model for predicting price based on squre feet, location, and their interaction
fit2 <- lm(Price ~ Sq_Ft + Location + Sq_Ft:Location,data=home.data)
summary(fit2)

#Do we need the interaction term
anova(fit1,fit2)


#Residual diagnostics
plot(fit2)


#######################################################################################
##Other Diagnostics
home.data <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 621/HomeData.txt",sep="\t",comment.char = "", header=TRUE, 
                        stringsAsFactors = FALSE)

class(home.data$Price)
class(home.data$Sq_Ft)
home.data$Price <- gsub(",","",home.data$Price)
home.data$Price <- gsub("\\$", "", home.data$Price)
home.data$Price <- as.numeric(home.data$Price)
home.data$Sq_Ft <- gsub(",","",home.data$Sq_Ft)
home.data$Sq_Ft <- as.numeric(home.data$Sq_Ft)
fit <- lm(Price ~ Sq_Ft+ Bedrooms + Baths, data=home.data)
summary(fit)


#Hats
lev = hat(model.matrix(fit))
plot(lev)
p <- dim(model.matrix(fit))[2]
n <- dim(model.matrix(fit))[1]
abline(h=(2*p)/n, col="blue")
#Identify high leverage points
home.data[lev > (2*p)/n,]

#Studentized Residuals
r = rstudent(fit)
plot(r)
abline(h=2,col="blue")
#Identify outlier points
home.data[r > 2,]


#Cook's Distances
cook = cooks.distance(fit)
plot(cook)
abline(h=1,col="blue")
abline(h=4/n,col="red")
abline(h=3*mean(cook),col="green")

#Remove obvious influential point
home.data2 <- home.data[-121,]

#Redo fit 
fit2 <- lm(Price ~ Sq_Ft + Location, data=home.data2)
summary(fit2)
plot(fit2)

##Examining Multicollinearity
pairs(home.data2[,4:7])
cor(home.data2[,4:7])
library(car)
fit3 <- lm(Price ~ Sq_Ft + Bedrooms + Baths + Location, data=home.data2)
vif(fit3) 

#LASSO 
library(glmnet)
x <- model.matrix(fit3)
x <- x[,-1]
homelasso <- glmnet(x=x, y=home.data2[,7])
plot(homelasso)
coef(homelasso)

