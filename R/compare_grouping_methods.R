#' Compare Grouping Results Across Multiple Configurations
#'
#' Runs group_lynx_families() with multiple ordering methods and clustering
#' algorithms to assess sensitivity and find optimal configuration. Tests
#' 30 different combinations: 2 clustering methods × 15 ordering strategies
#' (time, pca1, pca2, north-south, east-west each forward/reverse + 5 random seeds).
#'
#' @param data An sf object containing lynx observations with columns:
#'   rovbase_id, datotid_fra, datotid_til, byttedyr, geometry
#'   (same format as group_lynx_families).
#' @param optimize_group_count Logical. Apply group count optimization in each run?
#'   Default TRUE.
#' @param optimize_distances Logical. Apply distance optimization in each run?
#'   Default TRUE.
#' @param hclust_poly Numeric. Polynomial exponent for hierarchical clustering.
#'   Default 1.
#' @param group_col Character. Name of the group column to create/use.
#'   Default "group_id". Must match the column name used in group_lynx_families().
#'
#' @return A data.frame with comparison metrics:
#'   \itemize{
#'     \item ordering_method - Method used to order observations
#'     \item reversed - Whether ordering was reversed (logical)
#'     \item n_groups_hierarchical - Number of groups with hierarchical clustering
#'     \item n_groups_custom - Number of groups with custom clustering
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(gaupefam)
#'
#' # Compare all methods
#' comparison <- compare_grouping_methods(
#'   data = lynx_family_test_data,
#'   optimize_group_count = TRUE,
#'   optimize_distances = TRUE
#' )
#'
#' # View results
#' print(comparison)
#'
#' # Find configuration with fewest groups
#' comparison[which.min(comparison$n_groups_hierarchical), ]
#' comparison[which.min(comparison$n_groups_custom), ]
#'
#' # Compare clustering methods
#' summary(comparison$n_groups_hierarchical)
#' summary(comparison$n_groups_custom)
#' }
compare_grouping_methods <- function(data,
                                     optimize_group_count = TRUE,
                                     optimize_distances = TRUE,
                                     hclust_poly = 1,
                                     group_col = "group_id") {
  # Input validation
  if (!inherits(data, "sf")) {
    stop("'data' must be an sf object")
  }

  required_cols <- c("rovbase_id", "datotid_fra", "datotid_til", "byttedyr")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("'data' is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Define all ordering strategies to test
  ordering_configs <- expand.grid(
    method = c("time", "pca1", "pca2", "north-south", "east-west"),
    reversed = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  results <- list()

  # Test standard orderings (forward and reverse)
  for (i in seq_len(nrow(ordering_configs))) {
    config <- ordering_configs[i, ]

    # Hierarchical clustering
    result_h <- group_lynx_families(
      data = data,
      clustering_method = "cluster_hierarchical",
      ordering_method = config$method,
      reversed = config$reversed,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      hclust_poly = hclust_poly,
      group_col = group_col
    )

    # Custom clustering
    result_c <- group_lynx_families(
      data = data,
      clustering_method = "cluster_custom",
      ordering_method = config$method,
      reversed = config$reversed,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      group_col = group_col
    )

    results[[i]] <- data.frame(
      ordering_method = config$method,
      reversed = config$reversed,
      n_groups_hierarchical = length(unique(result_h[[group_col]])),
      n_groups_custom = length(unique(result_c[[group_col]])),
      stringsAsFactors = FALSE
    )
  }

  # Test random orderings with different seeds
  for (seed in 1:5) {
    set.seed(seed)

    result_h <- group_lynx_families(
      data = data,
      clustering_method = "cluster_hierarchical",
      ordering_method = "random",
      reversed = FALSE,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      hclust_poly = hclust_poly,
      group_col = group_col
    )

    result_c <- group_lynx_families(
      data = data,
      clustering_method = "cluster_custom",
      ordering_method = "random",
      reversed = FALSE,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      group_col = group_col
    )

    results[[nrow(ordering_configs) + seed]] <- data.frame(
      ordering_method = paste0("random_seed", seed),
      reversed = FALSE,
      n_groups_hierarchical = length(unique(result_h[[group_col]])),
      n_groups_custom = length(unique(result_c[[group_col]])),
      stringsAsFactors = FALSE
    )
  }

  # Combine results
  comparison <- do.call(rbind, results)
  rownames(comparison) <- NULL

  comparison
}
