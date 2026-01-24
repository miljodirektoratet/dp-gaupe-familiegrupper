## Code to prepare `lynx_test_data` dataset
## This creates a small test dataset for testing clustering functions
## for lynx family group grouping.
## Group 1: Bymarka, Trondheim (63.4°N, 10.4°E)
## Group 2: Nordmarka, Oslo (60.0°N, 10.7°E)
library(sf)

# Create test dataset: 8 lynx observations in Norway
# Group 1: 3 observations in Bymarka, Trondheim (spatially and temporally close)
# Group 2: 4 observations in Nordmarka, Oslo (spatially and temporally close)
lynx_family_test_data <- st_sf(
  rovbase_id = 1:7,
  datotid_fra = as.POSIXct(c(
    # Group 1 - Bymarka, Trondheim (close in time)
    "2026-01-01 10:00:00",
    "2026-01-03 14:00:00",
    "2026-01-04 08:00:00",
    # Group 2 - Nordmarka, Oslo (close in time)
    "2026-01-02 09:00:00",
    "2026-01-03 11:00:00",
    "2026-01-04 13:00:00",
    "2026-01-05 15:00:00"
  ), tz = "UTC"),
  datotid_til = as.POSIXct(c(
    # Group 1 - Bymarka, Trondheim
    "2026-01-02 18:00:00",
    "2026-01-04 20:00:00",
    "2026-01-05 12:00:00",
    # Group 2 - Nordmarka, Oslo
    "2026-01-03 17:00:00",
    "2026-01-04 19:00:00",
    "2026-01-05 21:00:00",
    "2026-01-06 23:00:00"
  ), tz = "UTC"),
  byttedyr = c(
    # Group 1 - Bymarka: High biomass area
    "High_biomass",
    "High_biomass",
    "High_biomass",
    # Group 2 - Nordmarka: High biomass area
    "High_biomass",
    "High_biomass",
    "High_biomass",
    "High_biomass"
  ),
  geometry = st_sfc(
    # Group 1 - Bymarka, Trondheim
    st_point(c(10.30, 63.40)),  
    st_point(c(10.28, 63.42)),  
    st_point(c(10.32, 63.38)),  
    # Group 2 - Nordmarka, Oslo
    st_point(c(10.70, 60.05)),  
    st_point(c(10.75, 60.07)),  
    st_point(c(10.68, 60.03)),  
    st_point(c(10.72, 60.09)),  
    crs = 4326  
  )
)

# Transform to SWEREF99 TM (3006) to match expected CRS
lynx_family_test_data <- st_transform(lynx_family_test_data, 3006)

usethis::use_data(lynx_family_test_data, overwrite = TRUE)
