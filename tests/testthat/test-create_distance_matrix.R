test_that("create_distance_matrix calculates spatial distances correctly", {
  skip_if_not_installed("sf")
  skip_if_not_installed("s2")

  library(sf)

  # Use actual test data from package
  data(lynx_family_test_data, package = "gaupefam")

  result <- create_distance_matrix(lynx_family_test_data$geometry)

  # Check matrix properties
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 7) # 7 observations in test data
  expect_equal(ncol(result), 7)
  expect_true(isSymmetric(result))

  # Check diagonal is zero (same point to itself)
  expect_equal(diag(result), rep(0, 7))

  # Check values are non-negative
  expect_true(all(result >= 0))

  # Check off-diagonal values are positive
  expect_true(all(result[upper.tri(result)] > 0))

  # Check that observations within groups are closer than between groups
  # Group 1: obs 1-3 (Bymarka), Group 2: obs 4-7 (Nordmarka)
  within_group1 <- mean(result[1:3, 1:3][upper.tri(result[1:3, 1:3])])
  within_group2 <- mean(result[4:7, 4:7][upper.tri(result[4:7, 4:7])])
  between_groups <- mean(result[1:3, 4:7])

  expect_true(within_group1 < between_groups)
  expect_true(within_group2 < between_groups)

  # Within-group distances should be roughly 5-10 km (5000-10000 m)
  expect_true(within_group1 > 1000) # At least 1 km
  expect_true(within_group1 < 20000) # Less than 20 km
  expect_true(within_group2 > 1000)
  expect_true(within_group2 < 20000)
})

test_that("create_distance_matrix works with different geometry types", {
  skip_if_not_installed("sf")
  skip_if_not_installed("s2")

  library(sf)

  # Test with polygons
  test_polygons <- st_sfc(
    st_polygon(list(rbind(c(0, 0), c(1, 0), c(1, 1), c(0, 1), c(0, 0)))),
    st_polygon(list(rbind(c(2, 2), c(3, 2), c(3, 3), c(2, 3), c(2, 2)))),
    crs = 4326
  )

  result <- create_distance_matrix(test_polygons)

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 2)
  expect_true(isSymmetric(result))
})

test_that("create_distance_matrix validates inputs", {
  skip_if_not_installed("sf")
  skip_if_not_installed("s2")

  library(sf)

  # Test with non-sfc object
  expect_error(
    create_distance_matrix(data.frame(x = 1:3, y = 1:3)),
    "'geometry' must be an sfc geometry column"
  )

  # Test with empty geometry
  expect_error(
    create_distance_matrix(st_sfc()),
    "'geometry' must contain at least one feature"
  )
})

test_that("create_distance_matrix returns distances in meters", {
  skip_if_not_installed("sf")
  skip_if_not_installed("s2")

  library(sf)

  # Create two points approximately 111 km apart (1 degree latitude)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(10, 61)),
    crs = 4326
  )

  result <- create_distance_matrix(test_points)

  # Distance should be roughly 111,000 meters (1 degree at 60°N)
  # Using a loose tolerance since exact distance varies with spherical geometry
  expect_true(result[1, 2] > 100000)
  expect_true(result[1, 2] < 120000)
})
