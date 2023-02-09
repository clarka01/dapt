cars <- read.table("C:/Users/local_dedwards7/Desktop/R Files/car_data.txt",sep=',',header=TRUE)
cars_sub <- cars[,c("length","width","height","city.mpg", "highway.mpg")]

#Get variance-covariance matrix
covmat <- cov(cars_sub)
covmat

#Get correlation matrix
corrmat <- cor(cars_sub)
corrmat

#Get scatterplot matrix
pairs(~length+width+height+city.mpg+highway.mpg, data=cars_sub)

#Colormap on correlations
#install.packages("corrplot") #run first time only
library(corrplot)
corrplot(corrmat,method="color")


# Graphical Assessment of Multivariate Normality
x <- as.matrix(cars_sub) # n x p numeric matrix
center <- colMeans(x) # centroid
n <- nrow(x); 
p <- ncol(x); 
cov <- cov(x); 
d <- mahalanobis(x,center,cov) # distances 
qqplot(qchisq(ppoints(n),df=p),d,
       main="QQ Plot Assessing Multivariate Normality",
       ylab="Mahalanobis D2")
abline(a=0,b=1)