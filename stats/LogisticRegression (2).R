#Logistic Regression
#Read in data
mydata <- read.table("C:/Users/dedwards7/Desktop/Teaching/DAPT 621/adult.data.txt",header=TRUE, sep=",")

##Pre-process Data ##
#Replace ? with NA
levels(mydata$WorkClass)
mydata[mydata==" ?"] <- NA

#Work Class
mydata$work <- "Other"
mydata$work[!is.na(mydata$WorkClass) & (mydata$WorkClass==" Federal-gov" | mydata$WorkClass==" Local-gov" | mydata$WorkClass==" State-gov")] <- "Government"
mydata$work[!is.na(mydata$WorkClass) & (mydata$WorkClass==" Self-emp=inc" | mydata$WorkClass==" Self-emp-not-inc")] <- "Self-Employed"
mydata$work[!is.na(mydata$WorkClass) & (mydata$WorkClass==" Private")] <- "Private"
mydata$work[is.na(mydata$WorkClass)] <- NA
mydata$work <- as.factor(mydata$work)

#Education
mydata$educ <- as.character(mydata$education)
mydata$educ[mydata$educ==" Preschool" | mydata$educ==" 1st-4th" | mydata$educ==" 5th-6th" | mydata$educ==" 7th-8th" |
              mydata$educ==" 9th" | mydata$educ==" 10th" | mydata$educ== " 11th" | mydata$educ== " 12th"] <- "Less than High School"

mydata$educ[mydata$educ==" Assoc-acdm" | mydata$educ==" Assoc-voc"] <- "Associate"

mydata$educ[mydata$educ==" Doctorate" | mydata$educ==" Masters" | mydata$educ==" Prof-school"] <- "Advanced"
mydata$educ <- as.factor(mydata$educ)  

#Marital Status
mydata$marital <- as.character(mydata$marital.status)
mydata$marital[mydata$marital==" Married-AF-spouse" | mydata$marital==" Married-civ-spouse" | mydata$marital==" Married-spouse-absent"] <- "Married"
mydata$marital <- as.factor(mydata$marital)

#Occupation ??

#Native Country
mydata$native <- "Other"
mydata$native[!is.na(mydata$native.country) & (mydata$native.country==" United-States")] <- "United States"
mydata$native[is.na(mydata$native.country)] <- NA
mydata$native <- as.factor(mydata$native)



#Fit Logistic Regression Model
myglm <- glm(Over.Under ~ Age + work + educ + marital + occupation + relationship + race + sex + hours.wk + native,
             family=binomial, data=mydata)
summary(myglm)
drop1(myglm,test="Chisq")

library(caret)
pdata <- predict(myglm, type="response")
mydata2 <- na.omit(mydata)
convert <- as.factor(mydata2$Over.Under == " >50K")
confusionMatrix(data=as.factor(pdata > 0.5), reference=convert)

#odds ratios
exp(coef(myglm))
exp(cbind(OR=coef(myglm),confint(myglm)))
