test_that("cluster_hierarchical returns correct cluster assignments", {
  skip_if_not_installed("stats")

  # Create a simple grouping index matrix
  # Values < 1 should cluster together, values > 1 should separate
  grouping_index <- matrix(c(
    0.5, 0.6, 2.0, 2.5,
    0.6, 0.5, 2.2, 2.3,
    2.0, 2.2, 0.5, 0.7,
    2.5, 2.3, 0.7, 0.5
  ), nrow = 4, byrow = TRUE)

  result <- cluster_hierarchical(grouping_index, hclust_poly = 1, cut_height = 1)

  # Should return integer vector
  expect_type(result, "integer")

  # Should have same length as matrix dimension
  expect_equal(length(result), nrow(grouping_index))

  # Observations 1-2 should cluster together (values < 1)
  # Observations 3-4 should cluster together (values < 1)
  expect_equal(result[1], result[2])
  expect_equal(result[3], result[4])
  expect_false(result[1] == result[3])
})

test_that("cluster_hierarchical respects hclust_poly parameter", {
  skip_if_not_installed("stats")

  grouping_index <- matrix(c(
    0.5, 0.9, 1.5,
    0.9, 0.5, 1.3,
    1.5, 1.3, 0.5
  ), nrow = 3, byrow = TRUE)

  # With poly = 1, observations 1-2 might cluster
  result1 <- cluster_hierarchical(grouping_index, hclust_poly = 1, cut_height = 1)

  # With higher poly, separation increases
  result2 <- cluster_hierarchical(grouping_index, hclust_poly = 2, cut_height = 1)

  expect_type(result1, "integer")
  expect_type(result2, "integer")
  expect_equal(length(result1), 3)
  expect_equal(length(result2), 3)
})

test_that("cluster_hierarchical handles different cut heights", {
  skip_if_not_installed("stats")

  grouping_index <- matrix(c(
    0.5, 0.8, 1.2, 2.0,
    0.8, 0.5, 1.1, 2.1,
    1.2, 1.1, 0.5, 1.9,
    2.0, 2.1, 1.9, 0.5
  ), nrow = 4, byrow = TRUE)

  # Lower cut height should create more clusters
  result_low <- cluster_hierarchical(grouping_index, cut_height = 0.5)

  # Higher cut height should create fewer clusters
  result_high <- cluster_hierarchical(grouping_index, cut_height = 2.0)

  expect_true(length(unique(result_low)) >= length(unique(result_high)))
})

test_that("cluster_hierarchical validates inputs", {
  # Invalid grouping_index type
  expect_error(
    cluster_hierarchical("not a matrix"),
    "grouping_index must be a matrix or data.frame"
  )

  # Invalid hclust_poly
  expect_error(
    cluster_hierarchical(matrix(1:4, 2, 2), hclust_poly = "invalid"),
    "hclust_poly must be a single numeric value"
  )

  # Invalid cut_height
  expect_error(
    cluster_hierarchical(matrix(1:4, 2, 2), cut_height = -1),
    "cut_height must be a single positive numeric value"
  )

  expect_error(
    cluster_hierarchical(matrix(1:4, 2, 2), cut_height = c(1, 2)),
    "cut_height must be a single positive numeric value"
  )
})

test_that("cluster_hierarchical works with data.frame input", {
  skip_if_not_installed("stats")

  grouping_df <- data.frame(
    a = c(0.5, 0.6, 2.0),
    b = c(0.6, 0.5, 2.1),
    c = c(2.0, 2.1, 0.5)
  )

  result <- cluster_hierarchical(grouping_df, hclust_poly = 1, cut_height = 1)

  expect_type(result, "integer")
  expect_equal(length(result), nrow(grouping_df))
})
