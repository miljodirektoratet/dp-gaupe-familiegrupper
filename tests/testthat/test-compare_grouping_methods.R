test_that("compare_grouping_methods returns data.frame with expected structure", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data,
    optimize_group_count = TRUE,
    optimize_distances = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_equal(ncol(result), 4)
  expect_named(result, c("ordering_method", "reversed", "n_groups_hierarchical", "n_groups_custom"))
})

test_that("compare_grouping_methods tests all 15 ordering strategies", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  # Should have 15 rows: 5 methods × 2 directions + 5 random seeds
  expect_equal(nrow(result), 15)

  # Check ordering methods are present
  expected_methods <- c(
    "time", "pca1", "pca2", "north-south", "east-west",
    "random_seed1", "random_seed2", "random_seed3", "random_seed4", "random_seed5"
  )

  actual_methods <- unique(result$ordering_method)
  expect_true(all(expected_methods %in% actual_methods))
})

test_that("compare_grouping_methods validates data is sf object", {
  non_sf_data <- data.frame(
    rovbase_id = 1:3,
    datotid_fra = Sys.time() + 1:3,
    datotid_til = Sys.time() + 4:6,
    byttedyr = "High_biomass"
  )

  expect_error(
    compare_grouping_methods(data = non_sf_data),
    "'data' must be an sf object"
  )
})

test_that("compare_grouping_methods validates required columns", {
  incomplete_data <- lynx_family_test_data
  incomplete_data$byttedyr <- NULL

  expect_error(
    compare_grouping_methods(data = incomplete_data),
    "missing required columns"
  )
})

test_that("compare_grouping_methods returns positive group counts", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  expect_true(all(result$n_groups_hierarchical > 0))
  expect_true(all(result$n_groups_custom > 0))
})

test_that("compare_grouping_methods respects optimization parameters", {
  result_optimized <- compare_grouping_methods(
    data = lynx_family_test_data,
    optimize_group_count = TRUE,
    optimize_distances = TRUE
  )

  result_unoptimized <- compare_grouping_methods(
    data = lynx_family_test_data,
    optimize_group_count = FALSE,
    optimize_distances = FALSE
  )

  expect_equal(nrow(result_optimized), 15)
  expect_equal(nrow(result_unoptimized), 15)

  # Results should exist (counts may differ due to optimization)
  expect_true(all(result_optimized$n_groups_hierarchical > 0))
  expect_true(all(result_unoptimized$n_groups_hierarchical > 0))
})

test_that("compare_grouping_methods includes reversed ordering tests", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  # Should have both TRUE and FALSE in reversed column
  expect_true(any(result$reversed == TRUE))
  expect_true(any(result$reversed == FALSE))
})

test_that("compare_grouping_methods handles hclust_poly parameter", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data,
    hclust_poly = 1.5
  )

  expect_equal(nrow(result), 15)
  expect_true(all(result$n_groups_hierarchical > 0))
})

test_that("compare_grouping_methods random seeds produce consistent results", {
  # Run twice with same seeds should give same results
  set.seed(42)
  result1 <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  set.seed(42)
  result2 <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  # Results should be identical when using same random seed
  expect_equal(result1, result2)
})

test_that("compare_grouping_methods returns numeric group counts", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  expect_type(result$n_groups_hierarchical, "integer")
  expect_type(result$n_groups_custom, "integer")
})

test_that("compare_grouping_methods returns character ordering_method", {
  result <- compare_grouping_methods(
    data = lynx_family_test_data
  )

  expect_type(result$ordering_method, "character")
})
