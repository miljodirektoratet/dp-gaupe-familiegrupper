## code to prepare `no_county_names_2024` dataset goes here
## code to prepare `no_county_names_2024` dataset goes here
library(csdata)
library(dplyr)
library(stringr)

# Get Norway county names and location codes for 2024 borders
no_county_names_2024 <- csdata::nor_locations_names(border = 2024) |>
  dplyr::filter(stringr::str_detect(location_code, "^county")) |>
  dplyr::distinct(location_code, location_name)

# print(help("nor_locations_names", package = "csdata")) # nolint
# dplyr::glimpse(no_county_names_2024) # nolint
# print(head(no_county_names_2024)) # nolint

# Add attribution information as attributes
attr(no_county_names_2024, "source") <- "csdata package (https://github.com/csids/csdata)"
attr(no_county_names_2024, "border_year") <- 2024
attr(no_county_names_2024, "date_accessed") <- Sys.Date()

# Get Metadata
type <- class(no_county_names_2024)
col <- ncol(no_county_names_2024)
row <- nrow(no_county_names_2024)
size <- format(object.size(no_county_names_2024), units = "Kb")

# Create documentation snippet for R/data.R
cat("\n=== Copy this to R/data.R ===\n")
cat("#' Norway County Names and Location Codes (2024 borders)\n")
cat("#'\n")
cat("#' Names and location codes for Norwegian counties using 2024 administrative borders.\n")
cat("#'\n")
cat("#' @format A dataframe with", row, "rows and", col, "columns:\n")
cat("#' \\describe{\n")
cat("#'   \\item{location_code}{County code identifier (e.g., \"county03\")}\n")
cat("#'   \\item{location_name}{County name in Norwegian (e.g., \"Oslo\", \"Trondelag\")}\n")
cat("#' }\n")
cat("#'\n")
cat("#' @details\n")
cat("#' Data size:", size, "\n")
cat("#'\n")
cat("#' @source\n")
cat("#' \\describe{\n")
cat("#'   \\item{csdata package}{\\url{https://github.com/csids/csdata}}\n")
cat("#'   \\item{Border year}{2024}\n")
cat("#' }\n")
cat("#'\n")
cat("#' @references\n")
cat("#' Norwegian county names and codes from csdata package.\n")
cat("#' Data accessed on", as.character(attr(no_county_names_2024, "date_accessed")), "\n")
cat("#'\n")
cat("\"no_county_names_2024\"\n")
cat("\n=== End of documentation ===\n")

# Save dataset to /data/no_county_names_2024.rda
usethis::use_data(no_county_names_2024, overwrite = TRUE)
