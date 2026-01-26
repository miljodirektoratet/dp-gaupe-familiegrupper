#' Create Lines from Observations to Group Centers
#'
#' Creates line geometries connecting each observation to its group center.
#'
#' @param data An sf object of observations (points).
#' @param centers An sf object of group centers (points).
#' @param group_col The name of the grouping column (string). Default is "gruppe_id".
#' @param id_col The name of the observation ID column (string). Default is "rovbase_id".
#' @return An sf object of lines, each connecting an observation to its group center, with the observation ID as an attribute.
#' @details The function matches each observation to its group center and creates a line between them. CRS is inherited from the input data.
#' @importFrom sf st_coordinates st_linestring st_sfc st_sf st_crs
#' @importFrom dplyr left_join
#' @export
create_lines <- function(data, centers, group_col = "gruppe_id", id_col = "rovbase_id") {
  # Validate input
  if (!inherits(data, "sf")) stop("data must be an sf object.")
  if (!inherits(centers, "sf")) stop("centers must be an sf object.")
  if (!(group_col %in% names(data))) stop(paste0("data must have a '", group_col, "' column."))
  if (!(group_col %in% names(centers))) stop(paste0("centers must have a '", group_col, "' column."))
  if (!(id_col %in% names(data))) stop(paste0("data must have a '", id_col, "' column."))

  # Extract coordinates
  data_coords <- sf::st_coordinates(data)
  centers_coords <- sf::st_coordinates(centers)
  data[["obs_X"]] <- data_coords[, 1]
  data[["obs_Y"]] <- data_coords[, 2]
  centers[["cent_X"]] <- centers_coords[, 1]
  centers[["cent_Y"]] <- centers_coords[, 2]

  # Join center coordinates to observations
  merged <- dplyr::left_join(
    data,
    as.data.frame(centers)[, c(group_col, "cent_X", "cent_Y")],
    by = group_col
  )

  # Remove rows with missing center coordinates
  merged <- merged[!is.na(merged$cent_X) & !is.na(merged$cent_Y), ]

  # Create lines
  lines <- lapply(seq_len(nrow(merged)), function(i) {
    m <- matrix(
      c(merged$cent_X[i], merged$cent_Y[i], merged$obs_X[i], merged$obs_Y[i]),
      nrow = 2,
      byrow = TRUE
    )
    sf::st_sfc(sf::st_linestring(m), crs = sf::st_crs(data))
  })
  lines <- do.call(c, lines)

  # Create sf object with ID
  lines_sf <- sf::st_sf(
    geometry = lines,
    id = merged[[id_col]]
  )
  names(lines_sf)[names(lines_sf) == "id"] <- id_col
  return(lines_sf)
}
