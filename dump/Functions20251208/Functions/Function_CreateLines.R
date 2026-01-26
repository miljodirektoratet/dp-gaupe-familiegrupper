# This function create lines between centerpoints and observations

create_lines<-function(my.dat, my.dat_cent){
  # Importing centre coordinates to observations
  my.dat_cent$cent_X33<-st_coordinates(my.dat_cent)[,1]
  my.dat_cent$cent_Y33<-st_coordinates(my.dat_cent)[,2]

  my.dat$X33<-st_coordinates(my.dat)[,1]
  my.dat$Y33<-st_coordinates(my.dat)[,2]

  my.dat<-merge(my.dat, as.data.frame(my.dat_cent[,c("groupID1", "cent_X33", "cent_Y33")])[,1:3], by="groupID1")

  # Making line from observation to center point
  my.dat_lines<-as.data.frame(my.dat[!is.na(my.dat$cent_Y33),])
  rownames(my.dat_lines)<-1:nrow(my.dat_lines)
  ls <- lapply(1:nrow(my.dat_lines), function(x)
  {
    v <- as.numeric(my.dat_lines[x,c("cent_X33", "cent_Y33", "X33", "Y33")])
    m <- matrix(v, nrow = 2, byrow=TRUE)
    return(st_sfc(st_linestring(m), crs = 32633))
  })

  ls = Reduce(c, ls)
  my.dat_lines<-st_sf(ls)
  my.dat_lines$RovbaseID <- my.dat[!is.na(my.dat$cent_Y33),]$RovbaseID
#  my.dat_lines$RS <- my.dat[!is.na(my.dat$cent_Y33),]$RS

  return(my.dat_lines)
}
