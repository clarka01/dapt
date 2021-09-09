
# setwd("C:/Users/clark/Desktop/DAPT Courses/semester_2/622_stat_multivariate/assignment1")
# getwd() shows wd

#-------------------part 1:
library(corrplot)
library(dplyr)
library(tidyverse)

candybars <- read.table("CandyBars.txt",sep=',',header=TRUE)


candybars_sub <- candybars[,3:ncol(candybars)]


#Get variance-covariance matrix
covmat <- cov(candybars_sub)
covmat

#Get correlation matrix
corrmat <- cor(candybars_sub)
corrmat

#-------------------part 2:

#Get scatterplot matrix
pairs(candybars_sub)

#Colormap on correlations
#install.packages("corrplot") #run first time only
library(corrplot)
corrplot(corrmat,method="color")

#-------------------part 3:

#Fit univariate prop plots & histograms
library(ggplot2)
library(car)

totfat <-- candybars_sub$Total.fat.g #example of how to do this in R...
qqnorm(totfat, main = "tot fat")
qqline(totfat, col = "steelblue", lwd =2) #no confidence bands...
hist(totfat)
boxplot(totfat, horizontal = TRUE, main= 'totfat')


#------------------part 4:

# Graphical Assessment of Multivariate Normality
x <- as.matrix(candybars_sub) # n x p numeric matrix
center <- colMeans(x) # centroid
n <- nrow(x); 
p <- ncol(x); 
cov <- cov(x); 
d <- mahalanobis(x,center,cov) # distances 
qqplot(qchisq(ppoints(n),df=p),d,
       main="QQ Plot Assessing Multivariate Normality",
       ylab="Mahalanobis D2")
abline(a=0,b=1)


#==================================================PART II:
install.packages('devtools')
install.packages('ggbiplot')
library(devtools)
library(corrplot)
library(ggplot2)
library(ggbiplot)



# a)i)
#display EigenValues & corr matrix; use w/ scree plot & determine # PCs to retain

candybars <- read.table("CandyBars.txt",sep=',',header=TRUE)

candy_pca <- prcomp(candybars[,c(3:16)], scale=TRUE) #scale = true is running on correlation matrix

summary(candy_pca)
plot(candy_pca)

candy_loadings <- candy_pca$rotation


biplot(candy_pca)
scores <- as.data.frame(candy_pca$x)
p <- ggplot(data=scores, aes(x=PC1, y=PC2,colour=as.factor(candybars_sub$Size))) 
p + geom_hline(yintercept=0) + geom_vline(xintercept=0) + geom_point()

