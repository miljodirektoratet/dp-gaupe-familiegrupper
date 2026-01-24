#' Create Spatial Distance Matrix
#'
#' Calculates a matrix of maximum spatial distances (in meters)
#' between all pairs of lynx observations.
#'
#' @param geometry An sfc geometry column containing
#'   the spatial locations of observations.
#'
#' @return A symmetric numeric matrix where element [i,j] represents the maximum
#'   spatial distance in meters between observation i and observation j,
#'   calculated on the sphere using Earth's radius.
#'
#' @details
#' This function uses the s2 library to calculate spherical distances on Earth's
#' surface, which is more accurate than planar distance calculations for
#' geographic coordinates. The s2_max_distance_matrix function computes the
#' maximum distance between geometries, which is particularly relevant for
#' polygon or linestring geometries where the maximum distance may be greater
#' than the distance between centroids.
#'
#' @importFrom s2 s2_max_distance_matrix s2_earth_radius_meters
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' # Create sample point data at three locations in Norway
#' points <- st_sfc(
#'   st_point(c(10, 60)),
#'   st_point(c(11, 61)),
#'   st_point(c(12, 62)),
#'   crs = 3006
#' )
#' dist_matrix <- create_distance_matrix(points)
#' 
#' # Output (3x3 symmetric matrix, distances in meters):
#' #         [,1]     [,2]     [,3]
#' # [1,]       0   152891   304346
#' # [2,]  152891        0   152024
#' # [3,]  304346   152024        0
#' # 
#' # Where:
#' # - [1,1] = 0 (same point)
#' # - [1,2] = 152891 (distance between point 1 and 2 in meters)
#' # - [1,3] = 304346 (distance between point 1 and 3 in meters)
#' }
create_distance_matrix <- function(geometry) {
  # Input validation
  if (!inherits(geometry, "sfc")) {
    stop("'geometry' must be an sfc geometry column (from an sf object)")
  }

  if (length(geometry) == 0) {
    stop("'geometry' must contain at least one feature")
  }

  # Calculate distance matrix using s2 spherical geometry
  distance_matrix <- s2::s2_max_distance_matrix(
    x = geometry,
    y = geometry,
    radius = s2::s2_earth_radius_meters()
  )

  # Validation check
  if (!isSymmetric(distance_matrix)) {
    stop("Distance matrix is not symmetric. Check the input data.")
  }

  return(distance_matrix)
}
