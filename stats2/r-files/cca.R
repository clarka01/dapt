#Canonical Correlation Analysis
#install.packages("CCA")
library(CCA)
library(ggplot2)
library(GGally)
#import exercise data
exercise <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/R Files/Exercise.txt",sep=",",header=TRUE)
X <- as.matrix(cbind(exercise[,1:3]))
Y <- as.matrix(cbind(exercise[,4:6]))

#plot bivariate correlations
correl <- matcor(X,Y)
img.matcor(correl,type=2)
ggpairs(exercise)

#CCA
ex.cca <- cc(X,Y)
barplot(ex.cca$cor, xlab="Dimension", ylab="Canonical Correlations")
plt.cc(ex.cca, var.label=TRUE)

#Standardized Coefficients
s1 <- diag(sqrt(diag(cov(X))))
s1 %*% ex.cca$xcoef

s2 <- diag(sqrt(diag(cov(Y))))
s2 %*% ex.cca$ycoef

#####################################################################
# Nutrimouse Data Set: nutrition study in mice.  Forty mice were studied:
# 1. expressions of 120 genes measured in liver cells
# 2. concentrations of 21 hepatic fatty acids measured by gas chromatography
# 
# Mice are cross-classified according to two factors:
# 1. genotype: wild-type (WT) and PPAR-alpha deficient
# 2. diet: reference (REF), coconut oil (COC), sunflower oil (SUN), linseed oil (LIN), fish oil (FISH)

data("nutrimouse")
X <- as.matrix(nutrimouse$gene)
Y <- as.matrix(nutrimouse$lipid)

correl <- matcor(X,Y)
img.matcor(correl,type=2)

#CCA with a subset of the genes (mention regularized CCA)
Xr <- as.matrix(nutrimouse$gene[,sample(1:120,size=20)])
mouse.cca <- cc(Xr,Y)

barplot(mouse.cca$cor, xlab="Dimension", ylab="Canonical correlations")
plt.cc(mouse.cca,var.label=TRUE, ind.names=paste(nutrimouse$genotype, nutrimouse$diet, sep="-"))

#Standardized Coefficients
s1 <- diag(sqrt(diag(cov(Xr))))
s1 %*% mouse.cca$xcoef

s2 <- diag(sqrt(diag(cov(Y))))
s2 %*% mouse.cca$ycoef
