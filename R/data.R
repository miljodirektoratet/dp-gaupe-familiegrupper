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
