test_that("create_time_matrix calculates temporal distances correctly", {
  # Use actual test data from package
  data(lynx_family_test_data, package = "gaupefam")

  result <- create_time_matrix(
    lynx_family_test_data$datotid_fra,
    lynx_family_test_data$datotid_til
  )

  # Check matrix properties
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 7) # 7 observations in test data
  expect_equal(ncol(result), 7)
  expect_true(isSymmetric(result))

  # Check diagonal - should all be positive (max distance from start to end of each period)
  expect_true(all(diag(result) > 0))

  # Check all values are positive
  expect_true(all(result >= 0))

  # Note: We don't test temporal separation between groups because the test data
  # has overlapping time periods for both groups (Jan 1-6). The groups are
  # distinguished by spatial location, not temporal separation.
})

test_that("create_time_matrix handles overlapping periods", {
  # Overlapping periods
  activity_from <- as.POSIXct(c("2024-01-01", "2024-01-02"))
  activity_to <- as.POSIXct(c("2024-01-03", "2024-01-04"))

  result <- create_time_matrix(activity_from, activity_to)

  # Should have positive distances
  expect_true(all(result > 0))
  expect_true(isSymmetric(result))
})

test_that("create_time_matrix handles Date objects", {
  activity_from <- as.Date(c("2024-01-01", "2024-01-05"))
  activity_to <- as.Date(c("2024-01-02", "2024-01-06"))

  result <- create_time_matrix(activity_from, activity_to)

  expect_true(is.matrix(result))
  expect_equal(nrow(result), 2)
  expect_true(isSymmetric(result))
})

test_that("create_time_matrix validates inputs", {
  activity_from <- as.POSIXct(c("2024-01-01", "2024-01-05"))
  activity_to <- as.POSIXct(c("2024-01-02", "2024-01-06"))

  # Test mismatched lengths
  expect_error(
    create_time_matrix(activity_from, activity_to[1]),
    "'activity_from' and 'activity_to' must have the same length"
  )

  # Test NA values
  activity_from_na <- c(activity_from, as.POSIXct(NA))
  activity_to_na <- c(activity_to, as.POSIXct("2024-01-10"))
  expect_error(
    create_time_matrix(activity_from_na, activity_to_na),
    "must not contain NA values"
  )

  # Test invalid type
  expect_error(
    create_time_matrix(c(1, 2), activity_to),
    "'activity_from' must be POSIXct or Date"
  )

  expect_error(
    create_time_matrix(activity_from, c(1, 2)),
    "'activity_to' must be POSIXct or Date"
  )
})

test_that("create_time_matrix produces integer ceiled values", {
  # Create times that will produce fractional days
  activity_from <- as.POSIXct(c("2024-01-01 12:00:00", "2024-01-02 18:00:00"))
  activity_to <- as.POSIXct(c("2024-01-01 15:00:00", "2024-01-02 21:00:00"))

  result <- create_time_matrix(activity_from, activity_to)

  # All values should be integers (ceiled)
  expect_true(all(result == floor(result)))
})
