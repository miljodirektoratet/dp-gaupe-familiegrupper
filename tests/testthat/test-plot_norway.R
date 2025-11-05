# Tests for plot_norway.R module

test_that("data objects exist and have correct structure", {
  # Test data object: "no_county_geodata_2024"
  expect_true(exists("no_county_geodata_2024"))
  expect_s3_class(no_county_geodata_2024, "data.frame")
  expect_true(nrow(no_county_geodata_2024) > 0)

  # Test data object: "no_county_names_2024"
  expect_true(exists("no_county_names_2024"))
  expect_s3_class(no_county_names_2024, "data.frame")
  expect_true(nrow(no_county_names_2024) > 0)
  expect_true("location_code" %in% names(no_county_names_2024))
  expect_true("location_name" %in% names(no_county_names_2024))
})

test_that("helper function works correctly", {
  # Test helper function: generate_county_colors
  county_colors <- generate_county_colors(no_county_names_2024)
  expect_type(county_colors, "character")
  expect_true(length(county_colors) == nrow(no_county_names_2024))
  expect_true(all(names(county_colors) == no_county_names_2024$location_name))
})

test_that("plot functions create ggplot objects", {
  # Test plot_trondelag function
  plot_trondelag_result <- plot_trondelag()
  expect_s3_class(plot_trondelag_result, "ggplot")

  # Test plot_norway_counties function
  plot_norway_result <- plot_norway_counties()
  expect_s3_class(plot_norway_result, "ggplot")
})
