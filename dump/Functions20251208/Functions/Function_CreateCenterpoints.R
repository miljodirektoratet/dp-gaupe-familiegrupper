# This script creates the geometry for the centerpoints of the groupings, the observations and
# the lines that connect the observations and centerpoints

create_centerpoints<-function(my.dat) {
  # Extract coordinates to be able to create sentre points
  my.dat$X33<-st_coordinates(st_centroid(my.dat))[,1]
  my.dat$Y33<-st_coordinates(st_centroid(my.dat))[,2]
  
  # Making centre points for the groupings
  my.dat_cent<-ddply(as.data.frame(my.dat), .(groupID1), summarise,
                     cent_X33=mean(X33),
                     cent_Y33=mean(Y33))
  
  # Make the centroid spatial
  my.dat_cent<-st_as_sf(my.dat_cent,  
                        coords = c("cent_X33", "cent_Y33"), crs = 32633)
  
  return(my.dat_cent)
}
