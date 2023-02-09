library(knitr)


myLibraries <- c("knitr", "magrittr", "markdown", "dplyr", "ggplot2", "rpart", "nnet",
                 "caret", "rmarkdown", "Rcpp", "cluster", "NeuralNetTools",
                 "randomForest", "kernlab", "e1071", "dummies", "rgl", "reshape2",
                 "fpc", "ROCR")
install.packages(myLibraries)


lapply(myLibraries, library, character.only=TRUE)

3+3
3*3
3/3
3^3

sqrt(3)

(a <- c(1:9))

(b <- c(1,3,8,12))

(mylist <- rep("R is so cool", 5))

(A <- matrix(a,ncol=3,byrow=TRUE))

?matrix

my_data <- data.frame(A)
names(my_data) <- c("Col1", "Col2", "Col3")
my_data

my_function <- function(x) {
  x <- x + 1
  x
}
(my_result <- my_function(a))


senic_data <- read.table("SENIC.csv", header=TRUE, row.names=1, sep=",",
                        colClasses=c(rep("numeric",7),rep("factor",2),rep("numeric",9),
                                     rep("factor",2)))

head(senic_data)
senic_data <- senic_data[,-ncol(senic_data)]

head(senic_data)


adult_data <- read.table("adult_data.csv", header=TRUE, sep=",",
                       colClasses = c("numeric", "factor",
                      "numeric", "factor", "numeric", rep("factor",5),
                      rep("numeric",3), rep("factor",2)), na.strings=" ?")

head(adult_data)


write.csv(adult_data, file="adult_data_clean.csv", row.names=FALSE)


read.table("adult_data_clean.csv", header=TRUE, sep=",",
                        colClasses = c("numeric", "factor",
                       "numeric", "factor", "numeric", rep("factor",5),
                       rep("numeric",3), rep("factor",2)))

