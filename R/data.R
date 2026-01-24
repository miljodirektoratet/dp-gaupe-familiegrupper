# Dataset documentation

#' Dataset | Norway County Map Data (2024 borders)
#'
#' Geographical boundaries for Norwegian counties using 2024 administrative borders.
#'
#' @format A data.table with 4579 rows and 5 columns containing map coordinates:
#' \describe{
#'   \item{location_code}{County code identifier (e.g., "county03")}
#'   \item{long}{Longitude coordinate}
#'   \item{lat}{Latitude coordinate}
#'   \item{order}{Point order for polygon drawing}
#'   \item{group}{Group identifier for polygon grouping}
#' }
#'
#' @details
#' Data size: 0.2 Mb
#'
#' @source
#' \describe{
#'   \item{csmaps package}{\url{https://github.com/csids/csmaps}}
#'   \item{Original source}{Geonorge}
#'   \item{License}{Creative Commons BY 4.0 (CC BY 4.0)}
#' }
#'
#' @references
#' Norwegian county boundaries from Geonorge, processed via csmaps package.
#' Data accessed on 2025-09-23
#'
"no_county_geodata_2024"

#' Dataset | Norway County Names and Location Codes (2024 borders)
#'
#' Names and location codes for Norwegian counties using 2024 administrative borders.
#'
#' @format A dataframe with 15 rows and 2 columns:
#' \describe{
#'   \item{location_code}{County code identifier (e.g., "county03")}
#'   \item{location_name}{County name in Norwegian (e.g., "Oslo", "Trondelag")}
#' }
#'
#' @details
#' Data size: 10.1 Kb
#'
#' @source
#' \describe{
#'   \item{csdata package}{\url{https://github.com/csids/csdata}}
#'   \item{Border year}{2024}
#' }
#'
#' @references
#' Norwegian county names and codes from csdata package.
#' Data accessed on 2025-09-23
#'
"no_county_names_2024"

#' Dataset | Lynx Test Data
#'
#' A small synthetic dataset of lynx family observations for testing clustering functions.
#' Contains 7 observations with spatial locations, temporal data, and prey categories.
#' 3 observations are from Bymarka, Trondheim and 4 from Nordmarka, Oslo.
#'
#' @format An sf object with 7 rows and 5 columns:
#' \describe{
#'   \item{rovbase_id}{Unique observation identifier (1-5)}
#'   \item{datotid_fra}{Start datetime of activity period (POSIXct, UTC)}
#'   \item{datotid_til}{End datetime of activity period (POSIXct, UTC)}
#'   \item{byttedyr}{Prey biomass category: "High_biomass", "Low_biomass", or "Northern_reindeer"}
#'   \item{geometry}{Point geometry (POINT) in WGS84 (EPSG:4326), locations in southern Norway}
#' }
#'
#' @details
#' This test dataset spans:
#' \itemize{
#'   \item Temporal range: 2026-01-01 to 2026-01-16 (16 days)
#'   \item Spatial range: Approximately 250 km north-south extent
#'   \item Observations include varying temporal and spatial separations
#'   \item Designed to test ordering, distance calculations, and clustering algorithms
#' }
#'
#' @examples
#' \dontrun{
#' # Load test data
#' data(lynx_family_test_data)
#'
#' # Test ordering functions
#' ordered <- order_observations(lynx_family_test_data, which_order = "time")
#'
#' # Test matrix creation
#' time_mat <- create_time_matrix(lynx_family_test_data$datotid_fra, lynx_family_test_data$datotid_til)
#' dist_mat <- create_distance_matrix(lynx_family_test_data$geometry)
#' }
"lynx_family_test_data"
