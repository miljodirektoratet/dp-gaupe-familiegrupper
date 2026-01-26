# This function creates a distance matrix

create_distance_matrix<-function(geometry){
  distm<-s2::s2_max_distance_matrix(x=geometry, y=geometry, radius = s2::s2_earth_radius_meters())

  if(isSymmetric(distm)==FALSE) {stop('Distance matrix is not symmetrical, supply a symmetric distance matrix')}

  return(distm)
}
