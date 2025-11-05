## code to prepare `no_county_geodata_2024` dataset goes here
library(csmaps)

# Get data from csmaps package
no_county_geodata_2024 <- csmaps::nor_county_map_b2024_default_dt
# print(help("nor_county_map_b2024_default_dt", package = "csmaps")) # nolint
# dplyr::glimpse(no_county_geodata_2024) # nolint
# print(head(no_county_geodata_2024)) # nolint

# Add attribution information as attributes
attr(no_county_geodata_2024, "source") <- "csmaps package (https://github.com/csids/csmaps)"
attr(no_county_geodata_2024, "original_source") <- "Geonorge"
attr(no_county_geodata_2024, "license") <- "Creative Commons BY 4.0 (CC BY 4.0)"
attr(no_county_geodata_2024, "date_accessed") <- Sys.Date()

# Get Metadata
type <- class(no_county_geodata_2024)
col <- ncol(no_county_geodata_2024)
row <- nrow(no_county_geodata_2024)
size <- format(object.size(no_county_geodata_2024), units = "Mb")

# Create documentation snippet for R/data.R
cat("\n=== Copy this to R/data.R ===\n")
cat("#' Norway County Map Data (2024 borders)\n")
cat("#'\n")
cat("#' Geographical boundaries for Norwegian counties using 2024 administrative borders.\n")
cat("#'\n")
cat("#' @format A data.table with", row, "rows and", col, "columns containing map coordinates:\n")
cat("#' \\describe{\n")
cat("#'   \\item{location_code}{County code identifier (e.g., \"county03\")}\n")
cat("#'   \\item{long}{Longitude coordinate}\n")
cat("#'   \\item{lat}{Latitude coordinate}\n")
cat("#'   \\item{order}{Point order for polygon drawing}\n")
cat("#'   \\item{group}{Group identifier for polygon grouping}\n")
cat("#' }\n")
cat("#'\n")
cat("#' @details\n")
cat("#' Data size:", size, "\n")
cat("#'\n")
cat("#' @source\n")
cat("#' \\describe{\n")
cat("#'   \\item{csmaps package}{\\url{https://github.com/csids/csmaps}}\n")
cat("#'   \\item{Original source}{Geonorge}\n")
cat("#'   \\item{License}{Creative Commons BY 4.0 (CC BY 4.0)}\n")
cat("#' }\n")
cat("#'\n")
cat("#' @references\n")
cat("#' Norwegian county boundaries from Geonorge, processed via csmaps package.\n")
cat("#' Data accessed on", as.character(attr(no_county_geodata_2024, "date_accessed")), "\n")
cat("#'\n")
cat("\"no_county_geodata_2024\"\n")
cat("\n=== End of documentation ===\n")

# Save dataset to /data/no_county_geodata_2024.rda
usethis::use_data(no_county_geodata_2024, overwrite = TRUE)
