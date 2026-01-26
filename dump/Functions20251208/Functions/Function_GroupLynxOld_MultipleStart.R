
#source("Functions/Function_GroupLynxOld.R")

grouplynx_diff_starts<-function(RovbaseID, activity_from, activity_to, geometry, prey_class, clust, split_groups=TRUE, pretty_lines=TRUE){

  my.dat<-data.frame(RovbaseID=RovbaseID, activity_from=activity_from, activity_to=activity_to, prey_class=prey_class)
  my.dat<-st_as_sf(my.dat, geometry, crs=32633)

  custom_time<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                         which.order="time", reversed=F, pretty_lines=F)

  hclust_time<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                         which.order="time", reversed=F, pretty_lines=F)

  # Reversed time
  custom_time_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                             which.order="time", reversed=F, pretty_lines=F)

  hclust_time_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                             which.order="time", reversed=F, pretty_lines=F)


  # Sort rows according to a PCA1
  custom_pca1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                        geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                        which.order="pca1", reversed=F, pretty_lines=F)

  hclust_pca1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                        geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                        which.order="pca1", reversed=F, pretty_lines=F)

  # Reverse order of PCA1
  custom_pca1_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="pca1", reversed=T, pretty_lines=F)

  hclust_pca1_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                            which.order="pca1", reversed=T, pretty_lines=F)


  # Sort according to PCA2
  custom_pca2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                         which.order="pca2", reversed=F, pretty_lines=F)


  hclust_pca2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                         which.order="pca2", reversed=F, pretty_lines=F)

  # Reverse order of PCA2
  custom_pca2_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                             which.order="pca2", reversed=T, pretty_lines=F)


  hclust_pca2_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                             which.order="pca2", reversed=T, pretty_lines=F)


  # Sort rows according to north-south
  custom_north<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                          geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                          which.order="north", reversed=F, pretty_lines=F)


  hclust_north<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                          geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                          which.order="north", reversed=F, pretty_lines=F)

  # Reverse order of north
  custom_north_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                              geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                              which.order="north", reversed=T, pretty_lines=F)


    hclust_north_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                              geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                              which.order="north", reversed=T, pretty_lines=F)


  # Sort rows according to east-west
custom_east<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                      geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                       which.order="east", reversed=F, pretty_lines=F)


  hclust_east<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                         geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                         which.order="east", reversed=F, pretty_lines=F)

  # Reverse order of east-west
 custom_east_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="east", reversed=T, pretty_lines=F)


  hclust_east_rev<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                             which.order="east", reversed=T, pretty_lines=F)

  # Random1
  set.seed(1)
  custom_random1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                             which.order="random", reversed=F, pretty_lines=F)

  hclust_random1<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                             geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                             which.order="random", reversed=F, pretty_lines=F)

  # Random2
  set.seed(2)
  custom_random2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  hclust_random2<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to=my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  # Random3
  set.seed(3)
  custom_random3<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  hclust_random3<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  # Random4
  set.seed(4)
  custom_random4<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  hclust_random4<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  # Random5
  set.seed(5)
  custom_random5<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="custom", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

  hclust_random5<-grouplynx(RovbaseID = my.dat$RovbaseID, activity_from = my.dat$activity_from, activity_to =my.dat$activity_to,
                            geometry = my.dat$geometry, prey_class = my.dat$prey_class, clust="h_clust", save_shapefiles = FALSE,
                            which.order="random", reversed=F, pretty_lines=F)

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
