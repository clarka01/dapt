#Cluster Analysis
library(mdsr)
library(readxl)
library(dplyr)
library(ape)
library(mclust)
library(ggplot2)

#Read in data
college.data <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/CollUniv.txt",sep=",",header=TRUE)
college.data$AccRate <- as.numeric(sub("%","",college.data$AccRate))
college.data$ExpPerStudent <- as.numeric((sub("\\$","",college.data$ExpPerStudent)))
#college.data <- cbind(college.data[,1:2],apply(college.data[,3:7],2,as.numeric))


#Hierarchical Clustering
d <- dist(college.data[,3:7],method="euclidean")
hier.clust <- hclust(d,method="ward.D")
plot(hier.clust)
groups <- cutree(hier.clust,k=5)
rect.hclust(hier.clust,k=5,border="red")
aggregate(college.data[,3:7],list(groups),FUN=mean)

#Two-way clustering
mydata <- as.matrix(college.data[,3:7])
rownames(mydata) <- college.data[,1]
datascaled <- scale(mydata)
heatmap(datascaled)

#K-means clustering
library(factoextra)
#fviz_nbclust(college.data[,3:7],kmeans,method="gap_stat")
kmean.clust <- kmeans(college.data[,3:7],5)
aggregate(mydata,by=list(kmean.clust$cluster),FUN=mean)
new.data <- data.frame(college.data, kmean.clust$cluster)
fviz_cluster(kmean.clust,data=college.data[,3:7])

####################################################################
# Car Data

cars <- read.table("C:/Users/dedwards7/Desktop/DAPT 622/cars_mod.txt",sep=",",header=TRUE)

#Hierarchical Clustering
d <- dist(cars[,3:16],method="euclidean")
hier.clust <- hclust(d,method="ward.D")
plot(hier.clust)
groups <- cutree(hier.clust,k=3)
rect.hclust(hier.clust,k=3,border="red")
aggregate(cars[,3:16],list(groups),FUN=mean,na.rm=TRUE)

#Two-way clustering
mydata <- as.matrix(cars[,3:16])
rownames(mydata) <- cars[,1]
datascaled <- scale(mydata)
heatmap(datascaled)

#K-means clustering
fviz_nbclust(na.omit(cars[,3:16]),kmeans,method="gap_stat")
kmean.clust <- kmeans(na.omit(cars[,3:16]),3)
aggregate(na.omit(cars[,3:16]),by=list(kmean.clust$cluster),FUN=mean)
new.data <- data.frame(na.omit(cars), kmean.clust$cluster)
fviz_cluster(kmean.clust,data=na.omit(cars[,3:16]))

#######More Clustering Examples 

#hierarchical clustering
download.file("https://www.fueleconomy.gov/feg/epadata/16data.zip",destfile="C:/Users/dedwards7/Desktop/fueleconomy.zip")
unzip("C:/Users/dedwards7/Desktop/fueleconomy.zip",exdir="C:/Users/dedwards7/Desktop/data")

filenames <- list.files("C:/Users/dedwards7/Desktop/data",pattern="public\\.xlsx")
cars <- read_excel(paste("C:/Users/dedwards7/Desktop/data/",filenames,sep="")) %>% data.frame()
cars <- cars %>%
  rename(make = Mfr.Name, model=Carline, displacement = Eng.Displ,
         cylinders = X..Cyl, city_mpg = City.FE..Guide....Conventional.Fuel, 
         hwy_mpg = Hwy.FE..Guide....Conventional.Fuel, gears=X..Gears) %>%
  select(make, model, displacement, cylinders, gears, city_mpg, hwy_mpg) %>%
  distinct(model, .keep_all = TRUE) %>%
  filter(make=="Toyota")

rownames(cars) <- cars$model
glimpse(cars)

car_diffs <- dist(cars)
car_mat <- car_diffs %>% as.matrix()

car_diffs %>%
  hclust() %>%
  as.phylo() %>%
  plot(cex=0.5, label.offset=1)

#k-means clustering
BigCities <- world_cities %>%
  arrange(desc(population)) %>%
  head(4000) %>%
  select(longitude, latitude)

glimpse(BigCities)

city_clusts <- BigCities %>%
  kmeans(centers = 6) %>%
  fitted("classes") %>%
  as.character()

BigCities <- BigCities %>% mutate(cluster=city_clusts)

BigCities %>% ggplot(aes(x=longitude,y=latitude)) + geom_point(aes(color=cluster))
