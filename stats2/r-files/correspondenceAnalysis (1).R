library(factoextra)
library(FactoMineR)
library(graphics)

example <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/CorrespondenceAnalysis.txt",header=TRUE,sep=',')
cont.table <- xtabs(example$Count ~ example$Eye.Color+example$Hair.Color)

mosaicplot(cont.table,shade=TRUE, las=2)
chisq <- chisq.test(cont.table)
chisq

ca <- CA(cont.table,graph=FALSE) #correspondence analysis
summary(ca)

eigenvalues <- get_eigenvalue(ca)
fviz_screeplot(ca)
fviz_ca_biplot(ca) #Biplot

fviz_contrib(ca,choice="row",axes=1)
fviz_contrib(ca,choice="col",axes=1)

#################################################################

crime <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/CityCrimeData.txt",header=TRUE,sep=',')
crime.table <- xtabs(crime$Rate ~ crime$City + crime$Crime)

mosaicplot(crime.table,shade=TRUE,las=2)
chisq <- chisq.test(crime.table)
chisq

ca <- CA(crime.table,graph=FALSE) #correspondence analysis
summary(ca)

eigenvalues <- get_eigenvalue(ca)
fviz_screeplot(ca)
fviz_ca_biplot(ca) #Biplot

fviz_contrib(ca,choice="row",axes=1)
fviz_contrib(ca,choice="col",axes=1)

##################################################################
#Multiple Correspondence Analysis

diy <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/DoItYourself.txt",header=TRUE,sep=',')
diy <- diy[rep(1:nrow(diy),diy$Count),]

diy.mca <- MCA(diy[,1:5],graph=FALSE)
summary(diy.mca)

fviz_screeplot(diy.mca,addlabels=TRUE)
fviz_mca_biplot(diy.mca)
fviz_mca_var(diy.mca)
