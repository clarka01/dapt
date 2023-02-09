library(caret)
library(dplyr)
library(rgl)
library(rpart)
library(ROCR)
library(randomForest)


set.seed(12345)


home_data <- read.table("home_data_clean.csv", header=TRUE, row.names=1, sep=",",
                       comment.char="", colClasses=c("character", 
                       rep("factor",2), rep("numeric",4), rep("factor",3))) 


adult_data <- read.table("adult_data.csv", header=TRUE, sep=",",
                       colClasses = c("numeric", "factor",
                      "numeric", "factor", "numeric", rep("factor",5),
                      rep("numeric",3), rep("factor",2)), na.strings=" ?")



load("eva_2019.rda")


price_sq_ft_lm <- lm(Price ~ Sq..Ft., data=home_data)
summary(price_sq_ft_lm)


plot(home_data$Sq..Ft., home_data$Price, xlab="Square Footage", ylab="Price",
    pch=16, col="blue")
abline(price_sq_ft_lm, lwd=3)


predict(price_sq_ft_lm)


predict(price_sq_ft_lm, list(Sq..Ft. = c(1200,1400,2000,3500)))


price_sq_ft_bath_df <- data.frame(home_data[,c("Sq..Ft.","Baths","Price")])
price_sq_ft_bath_lm <- lm(Price ~ ., data=price_sq_ft_bath_df)
summary(price_sq_ft_bath_lm)


plot3d(price_sq_ft_bath_df)
planes3d(a=price_sq_ft_bath_lm$coefficients[2],b=price_sq_ft_bath_lm$coefficients[3],
         c=-1.0, d=price_sq_ft_bath_lm$coefficients[1], alpha=0.05)


my_mlr_df <- home_data[,c("Price", "Location", "Bedrooms", "Baths", "Sq..Ft.", 
                       "Realtor.Group")]
my_mlr_lm <- lm(Price ~ ., data=my_mlr_df)
summary(my_mlr_lm)


my_mlr_summary <- summary(my_mlr_lm)
my_mlr_predictors <- names(which(my_mlr_summary$coefficients[,4] < 0.10))
my_mlr_predictors


my_adult_df <- adult_data[,c("Over.Under", "education", "capital.gain")]

my_adult_lr <- glm(Over.Under ~ ., data = my_adult_df, family=binomial("logit"))
summary(my_adult_lr)


exp(coef(my_adult_lr))


my_adult_predict <- predict(my_adult_lr, my_adult_df, type="response")
my_adult_predict_class <- character(length(my_adult_predict))
my_adult_predict_class[my_adult_predict < 0.5] <- "< $50k"
my_adult_predict_class[my_adult_predict >= 0.5] <- ">= $50k"
my_adult_cm <- table(my_adult_df$Over.Under, my_adult_predict_class)
my_adult_cm


summary(my_adult_df$Over.Under)


my_weights <- numeric(nrow(my_adult_df))
my_weights[my_adult_df$Over.Under == " <=50K"] <- 1 
my_weights[my_adult_df$Over.Under == " >50K"]  <- 2


my_adult_lr <- glm(Over.Under ~ ., data = my_adult_df, family=binomial("logit"),
                 weights=my_weights)
my_adult_predict <- predict(my_adult_lr, my_adult_df, type="response")
my_adult_predict_class <- character(length(my_adult_predict))
my_adult_predict_class[my_adult_predict < 0.5] <- "<50K"
my_adult_predict_class[my_adult_predict >= 0.5] <- ">=50K"
my_adult_cm <- table(my_adult_df$Over.Under, my_adult_predict_class)
my_adult_cm


my_adult_rpart <- rpart(Over.Under ~ ., data=my_adult_df, weights=my_weights)


plot(my_adult_rpart)
text(my_adult_rpart)


my_adult_rpart$variable.importance


train_rows <- createDataPartition(my_adult_df$Over.Under,
				 p=0.5,
				 list=FALSE)
train_adult <- my_adult_df[train_rows,]
test_adult <- my_adult_df[-train_rows,]


my_weights <- numeric(nrow(train_adult))
my_weights[train_adult$Over.Under == " <=50K"] <- 1
my_weights[train_adult$Over.Under == " >50K"]  <- 2

my_adult_rpart <- rpart(Over.Under ~ ., data=train_adult, weights=my_weights)
my_adult_predict_rpart <- predict(my_adult_rpart, newdata=test_adult, type="class")
table(test_adult$Over.Under, my_adult_predict_rpart)


my_adult_lr <- glm(Over.Under ~ ., data = train_adult, family=binomial("logit"),
               weights=my_weights)
adult_predict_lr <- predict(my_adult_lr, test_adult, type="response")
adult_pred_lr <- prediction(adult_predict_lr, test_adult$Over.Under)
adult_perf_lr <- performance(adult_pred_lr, "tpr", "fpr")

my_adult_rpart <- rpart(Over.Under ~ ., data=train_adult, weights=my_weights)
adult_predict_rpart  <- predict(my_adult_rpart, test_adult, type="prob")
adult_pred_rpart <- prediction(adult_predict_rpart[,2], test_adult$Over.Under)
adult_perf_rpart <- performance(adult_pred_rpart, "tpr", "fpr")


plot(adult_perf_lr, col=1)
plot(adult_perf_rpart, col=2, add=TRUE)
legend(0.7, 0.6, c("Log. Reg.", "Class. Tree"), col=1:2, lwd=3)


adult_lr_auc <- performance(adult_pred_lr, "auc")
adult_lr_auc@y.values[[1]]
adult_rpart_auc <- performance(adult_pred_rpart, "auc")
adult_rpart_auc@y.values[[1]]

