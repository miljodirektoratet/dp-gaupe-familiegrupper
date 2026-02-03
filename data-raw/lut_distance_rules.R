# Script to generate the distance rules lookup table for the package
# Run this script to (re)generate data/lut_distance_rules.rda

# Create the distance rules
prey_types <- c("High_biomass", "Low_biomass", "Southern_reindeer", "Northern_reindeer")
dist_rules <- data.frame(
  prey = rep(prey_types, each = 11),
  temporal_distance_days = rep(1:11, times = 4),
  distance_threshold_m = c(
    c(8, 12, 15, 16, 18, 19, 20, 20, 21, 21, 22),
    c(14, 20, 25, 28, 32, 33, 34, 35, 36, 39, 40),
    c(13, 18, 21, 24, 25, 27, 28, 29, 30, 30, 32),
    c(15, 22, 27, 31, 34, 36, 38, 39, 41, 42, 44)
  )
)

# All possible combinations
lut_distance_rules <- expand.grid(
  prey_class1 = prey_types,
  prey_class2 = prey_types,
  temporal_distance_days = 1:11,
  distance_threshold_m = NA_real_
)

# Calculate mean distance for each pair
for (i in seq_len(nrow(lut_distance_rules))) {
  temporal_distance_days <- lut_distance_rules$temporal_distance_days[i]
  prey_class1 <- lut_distance_rules$prey_class1[i]
  prey_class2 <- lut_distance_rules$prey_class2[i]
  lut_distance_rules$distance_threshold_m[i] <- mean(c(
    dist_rules$distance_threshold_m[
      dist_rules$temporal_distance_days == temporal_distance_days &
        dist_rules$prey == prey_class1
    ],
    dist_rules$distance_threshold_m[
      dist_rules$temporal_distance_days == temporal_distance_days &
        dist_rules$prey == prey_class2
    ]
  ))
}
lut_distance_rules$distance_threshold_m <- lut_distance_rules$distance_threshold_m * 1000

# Save as package data
usethis::use_data(lut_distance_rules, overwrite = TRUE)
