test_that("create_lines returns correct lines for each observation", {
  skip_if_not_installed("sf")
  skip_if_not_installed("dplyr")
  data(lynx_family_test_data, package = "gaupefam")

  # Add group and id columns if not present
  if (!"gruppe_id" %in% names(lynx_family_test_data)) {
    lynx_family_test_data$gruppe_id <- rep(1:2, c(3, 4))
  }
  if (!"rovbase_id" %in% names(lynx_family_test_data)) {
    lynx_family_test_data$rovbase_id <- seq_len(nrow(lynx_family_test_data))
  }

  centers <- create_center_points(lynx_family_test_data, group_col = "gruppe_id")
  lines <- create_lines(lynx_family_test_data, centers) # use defaults

  expect_s3_class(lines, "sf")
  expect_true(all(sf::st_geometry_type(lines) == "LINESTRING"))
  expect_equal(nrow(lines), nrow(lynx_family_test_data))
  expect_true(all(lines$rovbase_id %in% lynx_family_test_data$rovbase_id))
  expect_true(all(sf::st_crs(lines) == sf::st_crs(lynx_family_test_data)))
})
