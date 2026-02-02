test_that("split_groups merges groups when beneficial", {
  # Create scenario where groups 1 and 2 can merge
  group_assignments <- c(1, 1, 2, 3, 3)

  # Obs 1-3 can all group together
  grouping_indicator <- matrix(c(
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, FALSE, TRUE, TRUE
  ), nrow = 5, byrow = TRUE)

  distance_matrix <- matrix(c(
    0, 10, 15, 100, 105,
    10, 0, 12, 98, 103,
    15, 12, 0, 95, 100,
    100, 98, 95, 0, 8,
    105, 103, 100, 8, 0
  ), nrow = 5, byrow = TRUE)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_type(result, "double")
  expect_equal(length(result), 5)

  # Should have fewer groups than input (ideally 2 instead of 3)
  expect_true(length(unique(result)) <= length(unique(group_assignments)))

  # Obs 1-3 should be in same group
  expect_equal(result[1], result[2])
  expect_equal(result[2], result[3])

  # Obs 4-5 should be in same group
  expect_equal(result[4], result[5])

  # Groups should be different
  expect_false(result[1] == result[4])
})

test_that("split_groups handles single observation reassignment", {
  # Group with single observation that can join another group
  group_assignments <- c(1, 1, 2, 3, 3)

  # Obs 3 (group 2) can join group 1
  grouping_indicator <- matrix(c(
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, FALSE, TRUE, TRUE
  ), nrow = 5, byrow = TRUE)

  distance_matrix <- diag(5)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 5)
  expect_true(length(unique(result)) <= length(unique(group_assignments)))
})

test_that("split_groups preserves groups when splitting not beneficial", {
  # Groups that cannot be split
  group_assignments <- c(1, 1, 2, 2)

  # Groups are separate - cannot merge
  grouping_indicator <- matrix(c(
    TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, FALSE, FALSE,
    FALSE, FALSE, TRUE, TRUE,
    FALSE, FALSE, TRUE, TRUE
  ), nrow = 4, byrow = TRUE)

  distance_matrix <- diag(4)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 4)

  # Should maintain 2 groups
  expect_equal(length(unique(result)), 2)

  # Original groupings should be preserved
  expect_equal(result[1], result[2])
  expect_equal(result[3], result[4])
  expect_false(result[1] == result[3])
})

test_that("split_groups validates inputs", {
  valid_groups <- c(1, 1, 2)
  valid_indicator <- matrix(TRUE, 3, 3)
  valid_distance <- diag(3)

  # Invalid group_assignments type
  expect_error(
    split_groups("invalid", valid_indicator, valid_distance),
    "group_assignments must be a numeric or integer vector"
  )

  # Invalid grouping_indicator type
  expect_error(
    split_groups(valid_groups, "invalid", valid_distance),
    "grouping_indicator must be a matrix or data.frame"
  )

  # Invalid distance_matrix type
  expect_error(
    split_groups(valid_groups, valid_indicator, "invalid"),
    "distance_matrix must be a matrix or data.frame"
  )

  # Dimension mismatch
  expect_error(
    split_groups(valid_groups, matrix(TRUE, 4, 4), valid_distance),
    "grouping_indicator dimensions must match length of group_assignments"
  )

  expect_error(
    split_groups(valid_groups, valid_indicator, matrix(0, 4, 4)),
    "distance_matrix dimensions must match length of group_assignments"
  )
})

test_that("split_groups works with data.frame inputs", {
  group_assignments <- c(1, 1, 2)

  grouping_df <- data.frame(
    a = c(TRUE, TRUE, FALSE),
    b = c(TRUE, TRUE, FALSE),
    c = c(FALSE, FALSE, TRUE)
  )

  distance_df <- data.frame(
    a = c(0, 5, 100),
    b = c(5, 0, 105),
    c = c(100, 105, 0)
  )

  result <- split_groups(group_assignments, grouping_df, distance_df)

  expect_equal(length(result), 3)
  expect_true(is.numeric(result))
})

test_that("split_groups works with numeric (0/1) grouping indicator", {
  group_assignments <- c(1, 1, 2, 2)

  # Numeric grouping indicator
  grouping_indicator <- matrix(c(
    1, 1, 0, 0,
    1, 1, 0, 0,
    0, 0, 1, 1,
    0, 0, 1, 1
  ), nrow = 4, byrow = TRUE)

  distance_matrix <- diag(4)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 4)
  expect_true(is.numeric(result))
})

test_that("split_groups selects best alternative based on distance", {
  # Observation can join multiple groups - should pick one with minimum distance
  group_assignments <- c(1, 2, 2, 3, 3)

  # Obs 1 can join both group 2 and group 3
  grouping_indicator <- matrix(c(
    TRUE, TRUE, TRUE, TRUE, TRUE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, TRUE, TRUE, FALSE, FALSE,
    TRUE, FALSE, FALSE, TRUE, TRUE,
    TRUE, FALSE, FALSE, TRUE, TRUE
  ), nrow = 5, byrow = TRUE)

  # Group 2 is closer (distances 10, 12) than group 3 (distances 50, 55)
  distance_matrix <- matrix(c(
    0, 10, 12, 50, 55,
    10, 0, 5, 60, 65,
    12, 5, 0, 58, 63,
    50, 60, 58, 0, 8,
    55, 65, 63, 8, 0
  ), nrow = 5, byrow = TRUE)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 5)

  # Obs 1 should join group 2 (closer) rather than group 3
  expect_equal(result[1], result[2])
})

test_that("split_groups handles all observations in one group", {
  group_assignments <- c(1, 1, 1, 1)
  grouping_indicator <- matrix(TRUE, 4, 4)
  distance_matrix <- diag(4)

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 4)
  expect_equal(length(unique(result)), 1)
})

test_that("split_groups handles each observation in separate group", {
  group_assignments <- c(1, 2, 3, 4)
  grouping_indicator <- diag(4) == 1
  distance_matrix <- matrix(100, 4, 4)
  diag(distance_matrix) <- 0

  result <- split_groups(group_assignments, grouping_indicator, distance_matrix)

  expect_equal(length(result), 4)
  # Should maintain 4 separate groups (cannot merge)
  expect_equal(length(unique(result)), 4)
})
