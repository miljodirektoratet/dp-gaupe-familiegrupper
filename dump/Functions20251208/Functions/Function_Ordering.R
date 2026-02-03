# This script contain function that order the data, i.e. contain multiple starting points

this.order<-function(data, reversed=FALSE,
                     which.order=c("time", "pca1", "pca2", "north-south", "east-west", "random")[1]) {
  if(which.order=="time"){
    data<-data[order(data$activity_from, decreasing = reversed),]
    rownames(data)<-1:nrow(data)
  }

  if(which.order%in%c("pca1", "pca2")){
    data$X33<-as.numeric(st_coordinates(suppressWarnings(st_centroid(data)))[,1])
    data$Y33<-as.numeric(st_coordinates(suppressWarnings(st_centroid(data)))[,2])

    my_pca<-prcomp(~X33+Y33, data=as.data.frame(data), scale=TRUE)
    summary(my_pca)

    data$x1<-my_pca$x[,1]
    data$x2<-my_pca$x[,2]

    if(which.order%in%"pca1"){
      data<-data[order(data$x1, decreasing = reversed),]
    }
    if(which.order%in%"pca2"){
      data<-data[order(data$x2, decreasing = reversed),]
    }
    rownames(data)<-1:nrow(data)
  }

  if(which.order=="north"){

    data<-data[order(st_coordinates(st_centroid(data))[,2],decreasing = reversed),]
    rownames(data)<-1:nrow(data)
  }

  if(which.order=="east"){

    data<-data[order(st_coordinates(st_centroid(data))[,2],decreasing = reversed),]
    rownames(data)<-1:nrow(data)
  }

  if(which.order%in%"random"){
    data<-data[sample(1:nrow(data), size=nrow(data)),]
    rownames(data)<-1:nrow(data)
  }

  return(data)
}
