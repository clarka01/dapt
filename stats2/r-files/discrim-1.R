#Football Data
football <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/R files/football.txt",sep=',',header=TRUE)

#Linear Discriminant Analysis
library(MASS)
discrim <- lda(Group ~ ., data=football, na.action="na.omit")
discrim

#Percent Correct
discrim.values <- predict(discrim,football)
ct <-table(football$Group,discrim.values$class)
sum(diag(prop.table(ct)))

#Standardized coefficients are computed by multiplying the pooled standard deviation of 
#each variable by the corresponding discriminant coefficient

#Standardized Coefficients
library(Rfast)
vars <- football[,-1]
pooled <- pooled.cov(as.matrix(vars),football[,1])
sds <- diag(pooled)
std.coef <- discrim$scaling*sqrt(sds)

plot(discrim, col=as.integer(football$Group))

#install.packages("klaR")
library(klaR)
partimat(as.factor(Group) ~ HeadWidth + HeadCircum + FBEye + EyetoHeadTop + EartoHeadTop + JawWidth, data=football, method="lda")

#Quadratic Discriminant Analysis
QDA <- qda(Group ~ ., data=football, na.action="na.omit")
QDA

#Percent Correct
QDA.values <- predict(QDA,football)
ct <-table(football$Group,QDA.values$class)
sum(diag(prop.table(ct)))

partimat(as.factor(Group) ~ HeadWidth + HeadCircum + FBEye + EyetoHeadTop + EartoHeadTop + JawWidth, data=football, method="qda")


#Bank Data
library(MASS)
bank.data <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/R files/bank_data.txt",sep=',',header=TRUE)
bank_sub <- bank.data[,c("age","balance","day","duration","campaign","pdays","previous","target")]

bank_lda <- lda(target~.,data=bank_sub,na.action="na.omit")
bank_lda

discrim.values <- predict(bank_lda,bank_sub)
ct <-table(bank_sub$target,discrim.values$class)
sum(diag(prop.table(ct)))

#Standardized Coefficients
#vars <- bank_sub[,-8]
#sds <- apply(vars,2,sd)
#std.coef <- bank_lda$scaling*sds

vars <- bank_sub[,-8]
pooled <- pooled.cov(as.matrix(vars),as.factor(bank_sub$target))
sds <- diag(pooled)
std.coef <- bank_lda$scaling*sqrt(sds)

plot(bank_lda)


