library(dplyr)
library(dummies)
library(rgl)
library(cluster)

set.seed(12345)


home_data <- read.table("home_data_clean.csv", header=TRUE, row.names=1, sep=",",
                       comment.char="", colClasses=c("character", 
                       rep("factor",2), rep("numeric",4), rep("factor",3))) 


senic_data <- read.table("SENIC.csv", header=TRUE, row.names=1, sep=",",
                        colClasses=c(rep("numeric",7),rep("factor",2),
                        rep("numeric",9), rep("factor",2)))


load("eva_2019.rda")


home_df <- dummy.data.frame(home_data[,c("Bedrooms", 
                                         "Baths", 
                                         "Sq..Ft.", 
                                         "Price", 
                                         "Realtor.Group")],
                           names="Realtor.Group")
head(home_df)


home_df <- scale(home_df, center=TRUE, scale=TRUE)
head(home_df)


home_kmeans <- kmeans(home_df, centers=4)


home_pca <- prcomp(home_df, retx=TRUE)
plot(home_pca$x[,1:2], col=home_kmeans$cluster, pch=home_kmeans$cluster)


home_dist <- dist(home_df)
home_sil <- silhouette(home_kmeans$cluster, home_dist)
plot(home_sil)


summary(home_pca)


home_pca$rotation


plot(home_pca)


plot3d(home_pca$x[,1:3],col=home_kmeans$cluster)
