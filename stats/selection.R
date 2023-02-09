#Model Building and Selection
library(leaps)
library(MASS)
SENIC <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 621/SENIC.txt",sep=",",header=TRUE)

#Remove redundant variables
SENIC <- SENIC[,-c(1,8,9,14:18)]

#Run Stepwise Regression
null <- lm(Infection_pct ~ 1,data=SENIC)
full <- lm(Infection_pct ~ ., data=SENIC)

forward <- step(null,scope=list(lower=null,upper=full),direction="forward")
summary(forward)

backward <- step(full,direction="backward")
summary(backward)

both <- step(null,scope=list(upper=full),direction="both")
summary(both)

#Run All-Subsets Regression
allsubs <- regsubsets(Infection_pct ~ . , nbest=10, data=SENIC)
summary(allsubs)
plot(allsubs,scale="r2")

#Run LASSO
library(glmnet)
x <- model.matrix(lm(Infection_pct~.,data=SENIC))
x <- x[,-1]
lasso <- glmnet(x=x, y=SENIC[,3])
plot(lasso)
coef(lasso)