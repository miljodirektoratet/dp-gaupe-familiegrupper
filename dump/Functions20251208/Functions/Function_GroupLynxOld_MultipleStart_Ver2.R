
source("/home/rstudio/workspace/dump/Functions20251208/Functions/Function_GroupLynxOld_Ver2.R")

grouplynx_diff_starts<-function(RovbaseID, activity_from, activity_to, geometry, prey_class, clust, split=TRUE, pretty=TRUE, crs){

  my.dat<-data.frame(RovbaseID=RovbaseID, activity_from=activity_from, activity_to=activity_to, prey_class=prey_class)
  my.dat<-st_as_sf(my.dat, geometry, crs)

  custom_time<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                         which.order="time", reversed=F, pretty=F, crs=crs)

  hclust_time<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                         which.order="time", reversed=F, pretty=F, crs=crs)

  # Reversed time
  custom_time_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                             which.order="time", reversed=F, pretty=F, crs=crs)

  hclust_time_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                             which.order="time", reversed=F, pretty=F, crs=crs)


  # Sort rows according to a PCA1
  custom_pca1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                        geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                        which.order="pca1", reversed=F, pretty=F, crs=crs)

  hclust_pca1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                        geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                        which.order="pca1", reversed=F, pretty=F, crs=crs)

  # Reverse order of PCA1
  custom_pca1_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="pca1", reversed=T, pretty=F, crs=crs)

  hclust_pca1_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                            which.order="pca1", reversed=T, pretty=F, crs=crs)


  # Sort according to PCA2
  custom_pca2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                         which.order="pca2", reversed=F, pretty=F, crs=crs)


  hclust_pca2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                         which.order="pca2", reversed=F, pretty=F, crs=crs)

  # Reverse order of PCA2
  custom_pca2_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                             which.order="pca2", reversed=T, pretty=F, crs=crs)


  hclust_pca2_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                             which.order="pca2", reversed=T, pretty=F, crs=crs)


  # Sort rows according to north-south
  custom_north<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                          geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                          which.order="north", reversed=F, pretty=F, crs=crs)


  hclust_north<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                          geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                          which.order="north", reversed=F, pretty=F, crs=crs)

  # Reverse order of north
  custom_north_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                              geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                              which.order="north", reversed=T, pretty=F, crs=crs)


    hclust_north_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                              geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                              which.order="north", reversed=T, pretty=F, crs=crs)


  # Sort rows according to east-west
custom_east<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                      geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                       which.order="east", reversed=F, pretty=F, crs=crs)


  hclust_east<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                         which.order="east", reversed=F, pretty=F, crs=crs)

  # Reverse order of east-west
 custom_east_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="east", reversed=T, pretty=F, crs=crs)


  hclust_east_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                             which.order="east", reversed=T, pretty=F, crs=crs)

  # Random1
  set.seed(1)
  custom_random1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                             which.order="random", reversed=F, pretty=F, crs=crs)

  hclust_random1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                             which.order="random", reversed=F, pretty=F, crs=crs)

  # Random2
  set.seed(2)
  custom_random2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  hclust_random2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to=my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  # Random3
  set.seed(3)
  custom_random3<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  hclust_random3<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  # Random4
  set.seed(4)
  custom_random4<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  hclust_random4<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  # Random5
  set.seed(5)
  custom_random5<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  hclust_random5<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", ,
                            which.order="random", reversed=F, pretty=F, crs=crs)

  comp.df<-data.frame(sorting=c("time", "time_rev", "pca1", "pca1_rev", "pca2", "pca2_rev", "north", "north_rev",
                                "east", "east_rev", "random1", "random2", "random3", "random4", "random5"),
                      n.hclust=c(length(unique(hclust_time$groupID)),
                                 length(unique(hclust_time_rev$groupID)),
                                 length(unique(hclust_pca1$groupID)),
                                 length(unique(hclust_pca1_rev$groupID)),
                                 length(unique(hclust_pca2$groupID)),
                                 length(unique(hclust_pca2_rev$groupID)),
                                 length(unique(hclust_north$groupID)),
                                 length(unique(hclust_north_rev$groupID)),
                                 length(unique(hclust_east$groupID)),
                                 length(unique(hclust_east_rev$groupID)),
                                 length(unique(hclust_random1$groupID)),
                                 length(unique(hclust_random2$groupID)),
                                 length(unique(hclust_random3$groupID)),
                                 length(unique(hclust_random4$groupID)),
                                 length(unique(hclust_random5$groupID))),
                      n.custom=c(length(unique(custom_time$groupID)),
                                 length(unique(custom_time_rev$groupID)),
                                 length(unique(custom_pca1$groupID)),
                                 length(unique(custom_pca1_rev$groupID)),
                                 length(unique(custom_pca2$groupID)),
                                 length(unique(custom_pca2_rev$groupID)),
                                 length(unique(custom_north$groupID)),
                                 length(unique(custom_north_rev$groupID)),
                                 length(unique(custom_east$groupID)),
                                 length(unique(custom_east_rev$groupID)),
                                 length(unique(custom_random1$groupID)),
                                 length(unique(custom_random2$groupID)),
                                 length(unique(custom_random3$groupID)),
                                 length(unique(custom_random4$groupID)),
                                 length(unique(custom_random5$groupID)))
  )

  return(comp.df)
}
