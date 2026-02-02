test_that("group_lynx_families returns sf object with group_id column", {
  result <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom",
    ordering_method = "time"
  )

  expect_s3_class(result, "sf")
  expect_true("group_id" %in% names(result))
  expect_type(result$group_id, "integer")
})

test_that("group_lynx_families preserves input data structure", {
  result <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom"
  )

  # Should have all original columns plus group_id
  original_cols <- names(lynx_family_test_data)
  expect_true(all(original_cols %in% names(result)))
  expect_equal(nrow(result), nrow(lynx_family_test_data))
})

test_that("group_lynx_families validates clustering_method parameter", {
  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "invalid_method"
    ),
    "'clustering_method' must be 'cluster_hierarchical' or 'cluster_custom'"
  )
})

test_that("group_lynx_families validates ordering_method parameter", {
  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_custom",
      ordering_method = "invalid_order"
    ),
    "'ordering_method' must be one of"
  )
})

test_that("group_lynx_families validates required columns", {
  incomplete_data <- lynx_family_test_data
  incomplete_data$byttedyr <- NULL

  expect_error(
    group_lynx_families(
      data = incomplete_data,
      clustering_method = "cluster_custom"
    ),
    "missing required columns"
  )
})

test_that("group_lynx_families validates data is sf object", {
  non_sf_data <- data.frame(
    rovbase_id = 1:3,
    datotid_fra = Sys.time() + 1:3,
    datotid_til = Sys.time() + 4:6,
    byttedyr = "High_biomass"
  )

  expect_error(
    group_lynx_families(
      data = non_sf_data,
      clustering_method = "cluster_custom"
    ),
    "'data' must be an sf object"
  )
})

test_that("group_lynx_families works with cluster_hierarchical method", {
  result <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_hierarchical",
    ordering_method = "time",
    hclust_poly = 1
  )

  expect_s3_class(result, "sf")
  expect_true("group_id" %in% names(result))
  expect_true(all(result$group_id > 0))
})

test_that("group_lynx_families works with different ordering methods", {
  methods <- c("time", "pca1", "pca2", "north-south", "east-west", "random")

  for (method in methods) {
    result <- group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_custom",
      ordering_method = method
    )

    expect_s3_class(result, "sf")
    expect_true("group_id" %in% names(result))
  }
})

test_that("group_lynx_families respects reversed parameter", {
  result_forward <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom",
    ordering_method = "time",
    reversed = FALSE
  )

  result_reversed <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom",
    ordering_method = "time",
    reversed = TRUE
  )

  # Results should exist but may differ
  expect_s3_class(result_forward, "sf")
  expect_s3_class(result_reversed, "sf")
})

test_that("group_lynx_families respects optimization parameters", {
  # With optimizations
  result_optimized <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom",
    optimize_group_count = TRUE,
    optimize_distances = TRUE
  )

  # Without optimizations
  result_unoptimized <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom",
    optimize_group_count = FALSE,
    optimize_distances = FALSE
  )

  expect_s3_class(result_optimized, "sf")
  expect_s3_class(result_unoptimized, "sf")

  # Number of groups may differ due to optimization
  n_groups_optimized <- length(unique(result_optimized$group_id))
  n_groups_unoptimized <- length(unique(result_unoptimized$group_id))

  expect_true(n_groups_optimized > 0)
  expect_true(n_groups_unoptimized > 0)
})

test_that("group_lynx_families validates logical parameters", {
  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_custom",
      reversed = "not_logical"
    ),
    "must be logical"
  )

  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_custom",
      optimize_group_count = "not_logical"
    ),
    "must be logical"
  )
})

test_that("group_lynx_families validates hclust_poly parameter", {
  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_hierarchical",
      hclust_poly = -1
    ),
    "'hclust_poly' must be a positive number"
  )

  expect_error(
    group_lynx_families(
      data = lynx_family_test_data,
      clustering_method = "cluster_hierarchical",
      hclust_poly = "not_numeric"
    ),
    "'hclust_poly' must be a positive number"
  )
})

test_that("group_lynx_families assigns all observations to groups", {
  result <- group_lynx_families(
    data = lynx_family_test_data,
    clustering_method = "cluster_custom"
  )

  # No NA values in group_id
  expect_false(any(is.na(result$group_id)))

  # All group IDs are positive integers
  expect_true(all(result$group_id > 0))
  expect_true(all(result$group_id == floor(result$group_id)))
})
