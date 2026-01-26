# This function create a time matrix with distance in time between each observations


create_time_matrix<-function(activity_from, activity_to){
  time.array<-array(data = c(abs(outer(activity_from, activity_from, difftime, units="days"))+0.001,
                             abs(outer(activity_from, activity_to, difftime, units="days"))+0.001,
                             abs(outer(activity_to, activity_from, difftime, units="days"))+0.001,
                             abs(outer(activity_to, activity_to, difftime, units="days"))+0.001),
                    dim=c(length(activity_to), length(activity_to), 3))
  time.matrix<-apply(time.array, c(1,2), function(x){max(x, na.rm = TRUE)})
  time.matrix<-ceiling(time.matrix)


  if(any(is.na(time.matrix))) {stop('Time matrix contains NA, make sure that there are no NAs in the time columns')}
  if(isSymmetric(time.matrix)==FALSE) {stop('Time matrix is not symmetrical')}

  return(time.matrix)
}
