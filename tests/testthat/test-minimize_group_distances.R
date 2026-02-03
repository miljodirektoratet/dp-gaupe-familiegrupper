test_that("minimize_group_distances optimizes assignments", {
  # Create scenario where reassignment improves compactness
  group_assignments <- c(1, 1, 2, 2, 2)

  # All observations can group together
  grouping_indicator <- matrix(TRUE, 5, 5)

  # Distance matrix: obs 3 is closer to group 1 (obs 1-2) than group 2 (obs 4-5)
  distance_matrix <- matrix(c(
    0, 10, 15, 100, 105,
    10, 0, 18, 98, 103,
    15, 18, 0, 95, 100,
    100, 98, 95, 0, 8,
    105, 103, 100, 8, 0
  ), nrow = 5, byrow = TRUE)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_type(result, "double")
  expect_equal(length(result), 5)

  # Should have reassigned obs 3 to group 1 (closer)
  expect_equal(result[1], result[2])
  expect_equal(result[4], result[5])
})

test_that("minimize_group_distances preserves groups when optimal", {
  # Already optimal groupings
  group_assignments <- c(1, 1, 2, 2)

  grouping_indicator <- matrix(c(
    TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, TRUE, TRUE
  ), nrow = 4, byrow = TRUE)

  distance_matrix <- matrix(c(
    0, 5, 100, 105,
    5, 0, 98, 103,
    100, 98, 0, 8,
    105, 103, 8, 0
  ), nrow = 4, byrow = TRUE)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 4)
  expect_equal(length(unique(result)), 2)

  # Should maintain original groupings
  expect_equal(result[1], result[2])
  expect_equal(result[3], result[4])
  expect_false(result[1] == result[3])
})

test_that("minimize_group_distances handles no alternative groups", {
  # Each observation can only be in its current group
  group_assignments <- c(1, 1, 2, 2)

  # Strict grouping: can't mix groups
  grouping_indicator <- matrix(c(
    TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, TRUE, TRUE
  ), nrow = 4, byrow = TRUE)

  distance_matrix <- diag(4)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 4)

  # Should maintain original assignments
  expect_equal(result, group_assignments)
})

test_that("minimize_group_distances validates inputs", {
  valid_groups <- c(1, 1, 2)
  valid_distance <- diag(3)
  valid_indicator <- matrix(TRUE, 3, 3)

  # Invalid group_assignments
  expect_error(
    minimize_group_distances("invalid", valid_distance, valid_indicator),
    "group_assignments must be a numeric or integer vector"
  )

  # Invalid distance_matrix
  expect_error(
    minimize_group_distances(valid_groups, "invalid", valid_indicator),
    "distance_matrix must be a matrix or data.frame"
  )

  # Invalid grouping_indicator
  expect_error(
    minimize_group_distances(valid_groups, valid_distance, "invalid"),
    "grouping_indicator must be a matrix or data.frame"
  )

  # Dimension mismatches
  expect_error(
    minimize_group_distances(valid_groups, matrix(0, 4, 4), valid_indicator),
    "distance_matrix dimensions must match length of group_assignments"
  )

  expect_error(
    minimize_group_distances(valid_groups, valid_distance, matrix(TRUE, 4, 4)),
    "grouping_indicator dimensions must match length of group_assignments"
  )
})

test_that("minimize_group_distances works with data.frame inputs", {
  group_assignments <- c(1, 1, 2)

  distance_df <- data.frame(
    a = c(0, 5, 100),
    b = c(5, 0, 105),
    c = c(100, 105, 0)
  )

  grouping_df <- data.frame(
    a = c(TRUE, TRUE, FALSE),
    b = c(TRUE, TRUE, FALSE),
    c = c(FALSE, FALSE, TRUE)
  )

  result <- minimize_group_distances(group_assignments, distance_df, grouping_df)

  expect_equal(length(result), 3)
  expect_true(is.numeric(result))
})

test_that("minimize_group_distances works with numeric (0/1) grouping indicator", {
  group_assignments <- c(1, 1, 2, 2)

  # Numeric 0/1 grouping indicator
  grouping_indicator <- matrix(c(
    1, 1, 0, 0,
    1, 1, 0, 0,
    0, 0, 1, 1,
    0, 0, 1, 1
  ), nrow = 4, byrow = TRUE)

  distance_matrix <- diag(4)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 4)
  expect_true(is.numeric(result))
})

test_that("minimize_group_distances handles single observation per group", {
  group_assignments <- c(1, 2, 3)

  # All can group together
  grouping_indicator <- matrix(TRUE, 3, 3)

  # Obs 2 is between obs 1 and 3
  distance_matrix <- matrix(c(
    0, 10, 20,
    10, 0, 10,
    20, 10, 0
  ), nrow = 3, byrow = TRUE)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 3)
  expect_true(is.numeric(result))
})

test_that("minimize_group_distances converges to stable solution", {
  # Complex scenario requiring multiple iterations
  group_assignments <- c(1, 1, 2, 2, 3)

  grouping_indicator <- matrix(TRUE, 5, 5)

  distance_matrix <- matrix(c(
    0, 5, 50, 55, 100,
    5, 0, 48, 53, 98,
    50, 48, 0, 8, 90,
    55, 53, 8, 0, 88,
    100, 98, 90, 88, 0
  ), nrow = 5, byrow = TRUE)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 5)

  # Run again - should be stable (no changes)
  result2 <- minimize_group_distances(result, distance_matrix, grouping_indicator)
  expect_equal(result, result2)
})

test_that("minimize_group_distances handles all in one group", {
  group_assignments <- c(1, 1, 1, 1)
  grouping_indicator <- matrix(TRUE, 4, 4)
  distance_matrix <- diag(4)

  result <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)

  expect_equal(length(result), 4)
  expect_equal(length(unique(result)), 1)
})
