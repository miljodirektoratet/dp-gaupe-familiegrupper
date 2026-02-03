test_that("apply_distance_rules returns correct matrix and checks symmetry", {
  skip_if_not_installed("dplyr")
  data("lut_distance_rules", package = "gaupefam")
  # Example time matrix and prey classes matching the package LUT
  time_matrix <- matrix(c(0, 2, 3, 2, 0, 1, 3, 1, 0), nrow = 3, byrow = TRUE)
  prey_class <- c("High_biomass", "Low_biomass", "Southern_reindeer")
  # Should not error and should be symmetric
  result <- apply_distance_rules(time_matrix, prey_class, lut_distance_rules, max_days = 3)
  expect_true(isSymmetric(result))
  expect_equal(dim(result), dim(time_matrix))
  expect_true(all(diag(result) == Inf))
  expect_false(any(is.na(result)))
})
