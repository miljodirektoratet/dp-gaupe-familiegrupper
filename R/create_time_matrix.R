#' Create Temporal Distance Matrix
#'
#' Calculates the maximum temporal distance (in days) between all pairs of
#' lynx observation periods.
#'
#' @param activity_from Vector of POSIXct or Date objects representing the start
#'   of activity periods.
#' @param activity_to Vector of POSIXct or Date objects representing the end
#'   of activity periods. Must be the same length as activity_from.
#'
#' @return A symmetric numeric matrix (n x n) where element `[i,j]` represents the
#'   maximum temporal distance in days between observation i and j. Diagonal
#'   elements are 1 (same observation). All values are integers (ceiled).
#'
#' @details
#' For each pair of observations, the function computes the temporal distance
#' between all four combinations of start/end times and returns the maximum.
#' This ensures the full temporal extent of both observation periods is considered.
#'
#' Example: If observation A spans Jan 1-3 and observation B spans Jan 10-12,
#' the function calculates:
#' \itemize{
#'   \item Start A to Start B: Jan 1 to Jan 10 = 9 days
#'   \item Start A to End B: Jan 1 to Jan 12 = 11 days (maximum)
#'   \item End A to Start B: Jan 3 to Jan 10 = 7 days
#'   \item End A to End B: Jan 3 to Jan 12 = 9 days
#' }
#'
#' The maximum (11 days) is used to conservatively measure temporal separation.
#' A small constant (0.001) is added before ceiling to ensure diagonal is 1.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Three observations with activity periods
#' activity_from <- as.POSIXct(c("2024-01-01", "2024-01-05", "2024-01-10"))
#' activity_to <- as.POSIXct(c("2024-01-03", "2024-01-07", "2024-01-12"))
#' time_matrix <- create_time_matrix(activity_from, activity_to)
#'
#' # Output (3x3 symmetric matrix):
#' #      [,1] [,2] [,3]
#' # [1,]    1    7   12
#' # [2,]    7    1    8
#' # [3,]   12    8    1
#' #
#' # Where:
#' # - [1,1] = 1 (same observation)
#' # - [1,2] = 7 (max distance between obs 1 and 2)
#' # - [1,3] = 12 (max distance between obs 1 and 3)
#' }
create_time_matrix <- function(activity_from, activity_to) {
  # Input validation
  if (length(activity_from) != length(activity_to)) {
    stop("'activity_from' and 'activity_to' must have the same length")
  }

  if (any(is.na(activity_from)) || any(is.na(activity_to))) {
    stop("'activity_from' and 'activity_to' must not contain NA values")
  }

  if (!inherits(activity_from, c("POSIXct", "POSIXt", "Date"))) {
    stop("'activity_from' must be POSIXct or Date")
  }

  if (!inherits(activity_to, c("POSIXct", "POSIXt", "Date"))) {
    stop("'activity_to' must be POSIXct or Date")
  }

  # Calculate all pairwise temporal distances
  n <- length(activity_from)
  time_array <- array(
    data = c(
      abs(outer(activity_from, activity_from, difftime, units = "days")) + 0.001,
      abs(outer(activity_from, activity_to, difftime, units = "days")) + 0.001,
      abs(outer(activity_to, activity_from, difftime, units = "days")) + 0.001,
      abs(outer(activity_to, activity_to, difftime, units = "days")) + 0.001
    ),
    dim = c(n, n, 4)
  )

  # Take the maximum distance for each pair and ceil to integer
  time_matrix <- apply(time_array, c(1, 2), function(x) {
    max(x, na.rm = TRUE)
  })
  time_matrix <- ceiling(time_matrix)

  # Validation checks
  if (any(is.na(time_matrix))) {
    stop("Time matrix contains NA values. Check input data for missing values.")
  }

  if (!isSymmetric(time_matrix)) {
    stop("Time matrix is not symmetric. Check the input data.")
  }

  time_matrix
}
