test_that("create_centerpoints returns correct centroids for groups", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  skip_if_not_installed("rlang")
  data(lynx_family_test_data, package = "gaupefam")

  # Add a group column if not present (for test data compatibility)
  if (!"gruppe_id" %in% names(lynx_family_test_data)) {
    lynx_family_test_data$gruppe_id <- rep(1:2, c(3, 4))
  }

  result <- create_centerpoints(lynx_family_test_data, group_col = "gruppe_id")
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), length(unique(lynx_family_test_data$gruppe_id)))
  expect_true(all(sf::st_geometry_type(result) == "POINT"))
  expect_true(all(sf::st_crs(result) == sf::st_crs(lynx_family_test_data)))
})
