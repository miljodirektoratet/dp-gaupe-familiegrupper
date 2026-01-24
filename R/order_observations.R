#' Order Lynx Observations
#'
#' Orders spatial observations using different methods including temporal,
#' spatial (PCA), cardinal directions, or random ordering. This function is
#' used to determine the starting point for clustering algorithms.
#'
#' @param data An sf object containing lynx observations with geometry and
#'   temporal information.
#' @param reversed Logical. If TRUE, reverses the ordering direction.
#'   Default is FALSE.
#' @param which_order Character string specifying the ordering method. One of:
#'   \itemize{
#'     \item "time" - Order by temporal column
#'     \item "pca1" - Order by first principal component of coordinates
#'     \item "pca2" - Order by second principal component of coordinates
#'     \item "north-south" - Order by latitude (north to south)
#'     \item "east-west" - Order by longitude (east to west)
#'     \item "random" - Random ordering
#'   }
#'   Default is "time".
#' @param time_column Character string specifying the name of the temporal
#'   column to use for time-based ordering. Only used when which_order = "time".
#'   Default is "datotid_fra".
#'
#' @return An sf object with observations reordered according to the specified
#'   method and row names reset to sequential integers.
#'
#' @importFrom sf st_coordinates st_centroid
#' @importFrom stats prcomp
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Order by time (default)
#' ordered_data <- order_observations(lynx_data)
#'
#' # Order by time with custom column name
#' ordered_data <- order_observations(lynx_data, time_column = "activity_from")
#'
#' # Order by first principal component, reversed
#' ordered_data <- order_observations(lynx_data, reversed = TRUE, which_order = "pca1")
#'
#' # Random ordering
#' ordered_data <- order_observations(lynx_data, which_order = "random")
#' }
order_observations <- function(data,
                               reversed = FALSE,
                               which_order = c(
                                 "time", "pca1", "pca2",
                                 "north-south", "east-west",
                                 "random"
                               )[1],
                               time_column = "datotid_fra") {
  # Input variables validation
  if (!inherits(data, "sf")) {
    stop("'data' must be an sf object")
  }

  valid_orders <- c("time", "pca1", "pca2", "north-south", "east-west", "random")
  if (!which_order %in% valid_orders) {
    stop("'which_order' must be one of: ", paste(valid_orders, collapse = ", "))
  }

  if (!is.logical(reversed)) {
    stop("'reversed' must be logical (TRUE or FALSE)")
  }

  if (!is.character(time_column) || length(time_column) != 1) {
    stop("'time_column' must be a single character string")
  }

  # Time-based ordering (default)
  if (which_order == "time") {
    if (!time_column %in% names(data)) {
      stop("'data' must contain a '", time_column, "' column for time ordering")
    }
    data <- data[order(data[[time_column]], decreasing = reversed), ]
    rownames(data) <- seq_len(nrow(data))
  }

  # PCA-based ordering
  if (which_order %in% c("pca1", "pca2")) {
    coords <- sf::st_coordinates(suppressWarnings(sf::st_centroid(data)))
    x_coord <- as.numeric(coords[, 1])
    y_coord <- as.numeric(coords[, 2])

    my_pca <- stats::prcomp(~ x_coord + y_coord, scale = TRUE)

    data$pca_component_1 <- my_pca$x[, 1]
    data$pca_component_2 <- my_pca$x[, 2]

    if (which_order == "pca1") {
      data <- data[order(data$pca_component_1, decreasing = reversed), ]
    }
    if (which_order == "pca2") {
      data <- data[order(data$pca_component_2, decreasing = reversed), ]
    }
    rownames(data) <- seq_len(nrow(data))
  }

  # North-south ordering
  if (which_order == "north-south") {
    coords <- sf::st_coordinates(suppressWarnings(sf::st_centroid(data)))
    data <- data[order(coords[, 2], decreasing = reversed), ]
    rownames(data) <- seq_len(nrow(data))
  }

  # East-west ordering
  if (which_order == "east-west") {
    coords <- sf::st_coordinates(suppressWarnings(sf::st_centroid(data)))
    data <- data[order(coords[, 1], decreasing = reversed), ]
    rownames(data) <- seq_len(nrow(data))
  }

  # Random ordering
  if (which_order == "random") {
    data <- data[sample(seq_len(nrow(data)), size = nrow(data)), ]
    rownames(data) <- seq_len(nrow(data))
  }

  return(data)
}
