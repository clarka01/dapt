#Cars Data
cars <- read.table("C:/Users/local_dedwards7/Desktop/R files/car_data.txt",sep=',',header=TRUE)
cars_sub <- na.omit(cars[,c("body.style", "length","width","height","city.mpg", "highway.mpg", "price")])

pca <- prcomp(cars_sub[,c("length","width","height","city.mpg", "highway.mpg","price")], scale=TRUE) #scale = true is running on correlation matrix.
#can't put categorical variables in pca...
#gives eigenvectors [3:42pm]

#Get variance explained by each component
summary(pca)

#Scree plot (does bar chart, but still looking for elbow)
plot(pca)

#Loadings [3;45pm] doesn't scale them the same way as JMP, look at MAGNATUDE
loadings <- pca$rotation
loadings

#Biplot, 
#flipped on x-axis vs JMP (doesn't matter...)
biplot(pca)

#Nicer plot of scores
library(ggplot2)
scores <- as.data.frame(pca$x) #pca$x is scores so need to rename to get scores
p <- ggplot(data=scores, aes(x=PC1, y=PC2,colour=cars_sub$body.style)) 
p + geom_hline(yintercept=0) + geom_vline(xintercept=0) + geom_point() #adds additional elements to plot, including POINTS
#doesn't include "ggbiplot" library that includes rays. REMEMBER PLOT IS FLIPPED!!!! [3:57]


#HATCO data
hatco <- read.table("C:/Users/local_dedwards7/Desktop/R files/HATCO data.txt",sep=',',header=TRUE)
hatco_sub <- na.omit(hatco[,c(2:11)])

hatco_pca <- prcomp(hatco_sub[,c(1:7,9:10)],scale=TRUE)
summary(hatco_pca)
plot(hatco_pca)
loadings <- hatco_pca$rotation
biplot(hatco_pca)
scores <- as.data.frame(hatco_pca$x)
p <- ggplot(data=scores, aes(x=PC1, y=PC2,colour=as.factor(hatco_sub$Size))) 
p + geom_hline(yintercept=0) + geom_vline(xintercept=0) + geom_point()

#Wine data
#install.packages("devtools")
#library(devtools)
#install_github("vqv/ggbiplot")

library(ggbiplot)
wine <- read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data",sep=",")
colnames(wine) <- c("Cvs","Alcohol","Malic acid","Ash","Alcalinity of ash", "Magnesium", "Total phenols", "Flavanoids", "Nonflavanoid phenols", "Proanthocyanins", "Color intensity", "Hue", "OD280/OD315 of diluted wines", "Proline")
wineClasses <- factor(wine$Cvs)

pairs(wine[,-1], col = wineClasses, upper.panel = NULL, pch = 16, cex = 0.5)
legend("topright", bty = "n", legend = c("Cv1","Cv2","Cv3"), pch = 16, col = c("black","red","green"),xpd = T, cex = 2, y.intersp = 0.5)

winePCA <- prcomp(scale(wine[,-1]))
plot(winePCA)
summary(winePCA)
ggbiplot(winePCA,groups=wineClasses)
