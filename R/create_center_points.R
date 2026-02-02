#' Create Center Points for Grouped Observations
#'
#' Computes the centroid (mean X and Y coordinates) for each group in a spatial dataset and returns them as an sf object.
#'
#' @param data An sf object with a geometry column and a grouping column.
#' @param group_col The name of the grouping column (as a string or unquoted symbol). Default is "gruppe_id".
#' @return An sf object with one centroid point per group, using the same CRS as the input.
#' @details The function calculates the centroid of each group by averaging the centroid coordinates of all observations in that group. The output CRS is set to match the input data.
#' @importFrom sf st_coordinates st_centroid st_as_sf st_crs
#' @importFrom dplyr group_by summarise ungroup
#' @importFrom rlang enquo as_name
#' @export
create_center_points <- function(data, group_col = "gruppe_id") {
  # Validate input
  if (!inherits(data, "sf")) stop("Input must be an sf object.")
  if (!(group_col %in% names(data))) stop(paste0("Input must have a '", group_col, "' column."))

  # Calculate centroid coordinates for each observation
  centroids <- sf::st_centroid(data)
  coords <- sf::st_coordinates(centroids)
  data$X_cent <- coords[, 1]
  data$Y_cent <- coords[, 2]

  # Use dplyr for grouping and summarizing
  group_col_sym <- rlang::sym(group_col)
  group_centers <- data |>
    dplyr::as_tibble() |>
    dplyr::group_by(!!group_col_sym) |>
    dplyr::summarise(
      cent_X = mean(X_cent, na.rm = TRUE),
      cent_Y = mean(Y_cent, na.rm = TRUE),
      .groups = "drop"
    )

  # Convert to sf object with same CRS as input
  group_centers_sf <- sf::st_as_sf(
    group_centers,
    coords = c("cent_X", "cent_Y"),
    crs = sf::st_crs(data)
  )

  return(group_centers_sf)
}
