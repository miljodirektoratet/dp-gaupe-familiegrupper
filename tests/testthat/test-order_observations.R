test_that("order_observations handles time ordering correctly", {
  skip_if_not_installed("sf")

  # Create test data
  library(sf)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(11, 61)),
    st_point(c(12, 62)),
    crs = 4326
  )

  test_data <- st_sf(
    id = 1:3,
    datotid_fra = as.POSIXct(c("2024-01-03", "2024-01-01", "2024-01-02")),
    geometry = test_points
  )

  # Test time ordering (default, not reversed)
  result <- order_observations(test_data, which_order = "time")
  expect_equal(result$id, c(2, 3, 1))

  # Test reversed time ordering
  result_rev <- order_observations(test_data, reversed = TRUE, which_order = "time")
  expect_equal(result_rev$id, c(1, 3, 2))

  # Test with custom time column
  test_data_custom <- st_sf(
    id = 1:3,
    activity_from = as.POSIXct(c("2024-01-03", "2024-01-01", "2024-01-02")),
    geometry = test_points
  )
  result_custom <- order_observations(test_data_custom, which_order = "time", time_column = "activity_from")
  expect_equal(result_custom$id, c(2, 3, 1))
})

test_that("order_observations handles spatial ordering", {
  skip_if_not_installed("sf")

  library(sf)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(15, 65)),
    st_point(c(12, 62)),
    crs = 4326
  )

  test_data <- st_sf(
    id = 1:3,
    datotid_fra = as.POSIXct(c("2024-01-01", "2024-01-02", "2024-01-03")),
    geometry = test_points
  )

  # Test north-south ordering
  result_ns <- order_observations(test_data, which_order = "north-south")
  expect_equal(nrow(result_ns), 3)

  # Test east-west ordering
  result_ew <- order_observations(test_data, which_order = "east-west")
  expect_equal(nrow(result_ew), 3)
})

test_that("order_observations handles PCA ordering", {
  skip_if_not_installed("sf")

  library(sf)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(11, 61)),
    st_point(c(12, 62)),
    crs = 4326
  )

  test_data <- st_sf(
    id = 1:3,
    datotid_fra = as.POSIXct(c("2024-01-01", "2024-01-02", "2024-01-03")),
    geometry = test_points
  )

  # Test PCA1 ordering
  result_pca1 <- order_observations(test_data, which_order = "pca1")
  expect_equal(nrow(result_pca1), 3)
  expect_true("pca_component_1" %in% names(result_pca1))

  # Test PCA2 ordering
  result_pca2 <- order_observations(test_data, which_order = "pca2")
  expect_equal(nrow(result_pca2), 3)
  expect_true("pca_component_2" %in% names(result_pca2))
})

test_that("order_observations handles random ordering", {
  skip_if_not_installed("sf")

  library(sf)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(11, 61)),
    st_point(c(12, 62)),
    crs = 4326
  )

  test_data <- st_sf(
    id = 1:3,
    datotid_fra = as.POSIXct(c("2024-01-01", "2024-01-02", "2024-01-03")),
    geometry = test_points
  )

  # Test random ordering
  result_random <- order_observations(test_data, which_order = "random")
  expect_equal(nrow(result_random), 3)
  expect_setequal(result_random$id, 1:3)
})

test_that("order_observations validates inputs", {
  skip_if_not_installed("sf")

  library(sf)
  test_points <- st_sfc(
    st_point(c(10, 60)),
    st_point(c(11, 61)),
    crs = 4326
  )

  test_data <- st_sf(
    id = 1:2,
    datotid_fra = as.POSIXct(c("2024-01-01", "2024-01-02")),
    geometry = test_points
  )

  # Test invalid which_order
  expect_error(
    order_observations(test_data, which_order = "invalid"),
    "'which_order' must be one of"
  )

  # Test invalid reversed
  expect_error(
    order_observations(test_data, reversed = "yes"),
    "'reversed' must be logical"
  )

  # Test invalid time_column
  expect_error(
    order_observations(test_data, time_column = c("col1", "col2")),
    "'time_column' must be a single character string"
  )

  # Test non-sf input
  expect_error(
    order_observations(data.frame(id = 1:2)),
    "'data' must be an sf object"
  )

  # Test missing time column for time ordering
  test_data_no_time <- st_sf(
    id = 1:2,
    geometry = test_points
  )
  expect_error(
    order_observations(test_data_no_time, which_order = "time"),
    "'data' must contain a 'datotid_fra' column"
  )
})
