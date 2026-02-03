test_that("cluster_custom returns correct cluster assignments for simple case", {
  # Create a simple binary matrix with two clear groups
  grouping_indicator <- matrix(c(
    TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, TRUE, TRUE
  ), nrow = 4, byrow = TRUE)

  result <- cluster_custom(grouping_indicator)

  # Should return integer vector
  expect_type(result, "integer")

  # Should have same length as matrix dimension
  expect_equal(length(result), nrow(grouping_indicator))

  # Should have 2 unique groups
  expect_equal(length(unique(result)), 2)

  # Observations 1-2 should be in same group
  expect_equal(result[1], result[2])

  # Observations 3-4 should be in same group
  expect_equal(result[3], result[4])

  # Groups 1-2 and 3-4 should be different
  expect_false(result[1] == result[3])
})

test_that("cluster_custom handles incomplete linkage by removing conflicts", {
  # Create matrix where obs 1-2-3 form a chain but not all can group
  # 1 can group with 2, 2 can group with 3, but 1 cannot group with 3
  grouping_indicator <- matrix(c(
    TRUE, TRUE, FALSE,
    TRUE, TRUE, TRUE,
    FALSE, TRUE, TRUE
  ), nrow = 3, byrow = TRUE)

  result <- cluster_custom(grouping_indicator)

  expect_type(result, "integer")
  expect_equal(length(result), 3)

  # Since obs 1 cannot group with obs 3, algorithm should create groups
  # The exact grouping depends on iteration order, but all should be assigned
  expect_true(all(!is.na(result)))
})

test_that("cluster_custom handles single observation groups", {
  # Matrix where each observation can only group with itself
  grouping_indicator <- matrix(c(
    TRUE, FALSE, FALSE,
    FALSE, TRUE, FALSE,
    FALSE, FALSE, TRUE
  ), nrow = 3, byrow = TRUE)

  result <- cluster_custom(grouping_indicator)

  expect_type(result, "integer")
  expect_equal(length(result), 3)

  # Each observation should be in its own group
  expect_equal(length(unique(result)), 3)
})

test_that("cluster_custom handles all observations grouping together", {
  # Matrix where all observations can group with each other
  grouping_indicator <- matrix(TRUE, nrow = 4, ncol = 4)

  result <- cluster_custom(grouping_indicator)

  expect_type(result, "integer")
  expect_equal(length(result), 4)

  # All observations should be in the same group
  expect_equal(length(unique(result)), 1)
})

test_that("cluster_custom validates inputs", {
  # Invalid input type
  expect_error(
    cluster_custom("not a matrix"),
    "grouping_indicator must be a matrix or data.frame"
  )

  # Non-square matrix
  expect_error(
    cluster_custom(matrix(TRUE, nrow = 3, ncol = 4)),
    "grouping_indicator must be a square matrix"
  )
})

test_that("cluster_custom works with numeric input (0/1)", {
  # Numeric matrix with 0/1 values
  grouping_indicator <- matrix(c(
    1, 1, 0, 0,
    1, 1, 0, 0,
    0, 0, 1, 1,
    0, 0, 1, 1
  ), nrow = 4, byrow = TRUE)

  result <- cluster_custom(grouping_indicator)

  expect_type(result, "integer")
  expect_equal(length(result), 4)
  expect_equal(length(unique(result)), 2)
})

test_that("cluster_custom works with data.frame input", {
  grouping_df <- data.frame(
    a = c(TRUE, TRUE, FALSE),
    b = c(TRUE, TRUE, FALSE),
    c = c(FALSE, FALSE, TRUE)
  )

  result <- cluster_custom(grouping_df)

  expect_type(result, "integer")
  expect_equal(length(result), nrow(grouping_df))
})

test_that("cluster_custom handles complex conflict resolution", {
  # Create a scenario requiring conflict resolution
  # Obs 1 can group with 2,3,4 but 2,3,4 cannot all group together
  grouping_indicator <- matrix(c(
    TRUE, TRUE, TRUE, TRUE, FALSE,
    TRUE, TRUE, FALSE, FALSE, FALSE,
    TRUE, FALSE, TRUE, FALSE, FALSE,
    TRUE, FALSE, FALSE, TRUE, FALSE,
    FALSE, FALSE, FALSE, FALSE, TRUE
  ), nrow = 5, byrow = TRUE)

  result <- cluster_custom(grouping_indicator)

  expect_type(result, "integer")
  expect_equal(length(result), 5)

  # All observations should be assigned
  expect_true(all(!is.na(result)))

  # Obs 5 should be in its own group (can only group with itself)
  expect_true(result[5] != result[1])
})
