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
#' @param parallel Logical. Use parallel processing? Default TRUE.
#'   Requires 'parallel' package.
#' @param n_cores Integer. Number of cores to use for parallel processing.
#'   Default is detectCores() - 1.
#'
#' @return A data.frame with comparison metrics:
#'   \itemize{
#'     \item ordering_method - Method used to order observations
#'     \item reversed - Whether ordering was reversed (logical)
#'     \item n_groups_hierarchical - Number of groups with hierarchical clustering
#'     \item n_groups_custom - Number of groups with custom clustering
#'     \item time_hierarchical_min - Time in minutes for hierarchical clustering
#'     \item time_custom_min - Time in minutes for custom clustering
#'   }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(gaupefam)
#'
#' # Compare all methods (parallel)
#' comparison <- compare_grouping_methods(
#'   data = lynx_family_test_data,
#'   optimize_group_count = TRUE,
#'   optimize_distances = TRUE,
#'   parallel = TRUE
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
                                     group_col = "group_id",
                                     parallel = TRUE,
                                     n_cores = NULL) {
  # Input validation
  if (!inherits(data, "sf")) {
    stop("'data' must be an sf object")
  }

  required_cols <- c("rovbase_id", "datotid_fra", "datotid_til", "byttedyr")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("'data' is missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Setup parallel processing
  if (parallel) {
    if (!requireNamespace("parallel", quietly = TRUE)) {
      warning("'parallel' package not available. Running sequentially.")
      parallel <- FALSE
    } else {
      if (is.null(n_cores)) {
        n_cores <- max(1, parallel::detectCores() - 1)
      }
      cat("Parallel processing enabled with", n_cores, "cores\n")
    }
  }

  # Define all ordering strategies to test
  ordering_configs <- expand.grid(
    method = c("time", "pca1", "pca2", "north-south", "east-west"),
    reversed = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  # Calculate total number of tests (each config tests 2 clustering methods)
  n_standard_configs <- nrow(ordering_configs)
  n_random_configs <- 5
  total_configs <- n_standard_configs + n_random_configs
  current_config <- 0

  cat("\n========================================\n")
  cat("GROUPING METHOD COMPARISON\n")
  cat("========================================\n")
  cat("Total configurations to test:", total_configs, "\n")
  cat("  - Standard orderings:", n_standard_configs, "(2 clustering methods each)\n")
  cat("  - Random orderings:", n_random_configs, "(2 clustering methods each)\n")
  cat("Total grouping runs:", total_configs * 2, "\n")
  cat("========================================\n\n")

  # Function to test a single configuration
  test_config <- function(i, config, is_random = FALSE, seed = NULL) {
    if (is_random) {
      set.seed(seed)
      config_name <- paste0("random_seed", seed)
    } else {
      config_name <- sprintf("%s (reversed=%s)", config$method, config$reversed)
    }
    
    # Hierarchical clustering
    start_time_h <- Sys.time()
    result_h <- group_lynx_families(
      data = data,
      clustering_method = "cluster_hierarchical",
      ordering_method = if(is_random) "random" else config$method,
      reversed = if(is_random) FALSE else config$reversed,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      hclust_poly = hclust_poly,
      group_col = group_col
    )
    end_time_h <- Sys.time()
    time_h_min <- as.numeric(difftime(end_time_h, start_time_h, units = "mins"))
    n_groups_h <- length(unique(result_h[[group_col]]))

    # Custom clustering
    start_time_c <- Sys.time()
    result_c <- group_lynx_families(
      data = data,
      clustering_method = "cluster_custom",
      ordering_method = if(is_random) "random" else config$method,
      reversed = if(is_random) FALSE else config$reversed,
      optimize_group_count = optimize_group_count,
      optimize_distances = optimize_distances,
      group_col = group_col
    )
    end_time_c <- Sys.time()
    time_c_min <- as.numeric(difftime(end_time_c, start_time_c, units = "mins"))
    n_groups_c <- length(unique(result_c[[group_col]]))

    list(
      ordering_method = if(is_random) config_name else config$method,
      reversed = if(is_random) FALSE else config$reversed,
      n_groups_hierarchical = n_groups_h,
      n_groups_custom = n_groups_c,
      time_hierarchical_min = time_h_min,
      time_custom_min = time_c_min,
      config_name = config_name
    )
  }

  # Run tests (parallel or sequential)
  if (parallel) {
    cl <- parallel::makeCluster(n_cores)
    on.exit(parallel::stopCluster(cl))
    
    # Detect base path for package loading
    base_path <- if (grepl("/home/rstudio/workspace", getwd())) {
      "/home/rstudio/workspace"
    } else {
      "/home/wilaca/git/miljodirektoratet/dp-gaupe-familiegrupper"
    }
    
    # Export necessary objects to cluster
    parallel::clusterExport(cl, c("data", "optimize_group_count", "optimize_distances",
                                   "hclust_poly", "group_col", "test_config", 
                                   "ordering_configs", "base_path"),
                            envir = environment())
    
    # Load the entire package on each worker
    parallel::clusterEvalQ(cl, {
      library(sf)
      library(dplyr)
      devtools::load_all(base_path)
    })
    
    cat("Running standard orderings in parallel...\n")
    results_standard <- parallel::parLapply(cl, seq_len(nrow(ordering_configs)), function(i) {
      test_config(i, ordering_configs[i, ], is_random = FALSE)
    })
    
    cat("Running random orderings in parallel...\n")
    results_random <- parallel::parLapply(cl, 1:5, function(seed) {
      test_config(seed, NULL, is_random = TRUE, seed = seed)
    })
    
    results <- c(results_standard, results_random)
    
  } else {
    results <- list()
    
    # Test standard orderings (sequential)
    for (i in seq_len(nrow(ordering_configs))) {
      config <- ordering_configs[i, ]
      current_config <- current_config + 1
      
      cat(sprintf("[%d/%d] Testing: %s (reversed=%s)\n", 
                  current_config, total_configs, config$method, config$reversed))
      cat("----------------------------------------\n")
      
      res <- test_config(i, config, is_random = FALSE)
      
      cat(sprintf("  Hierarchical: %d groups (%.2f min)\n", 
                  res$n_groups_hierarchical, res$time_hierarchical_min))
      cat(sprintf("  Custom: %d groups (%.2f min)\n", 
                  res$n_groups_custom, res$time_custom_min))
      cat(sprintf("  Total time: %.2f min\n\n", 
                  res$time_hierarchical_min + res$time_custom_min))
      
      results[[i]] <- res
    }

    # Test random orderings (sequential)
    for (seed in 1:5) {
      current_config <- current_config + 1
      
      cat(sprintf("[%d/%d] Testing: random_seed%d\n", 
                  current_config, total_configs, seed))
      cat("----------------------------------------\n")
      
      res <- test_config(seed, NULL, is_random = TRUE, seed = seed)
      
      cat(sprintf("  Hierarchical: %d groups (%.2f min)\n", 
                  res$n_groups_hierarchical, res$time_hierarchical_min))
      cat(sprintf("  Custom: %d groups (%.2f min)\n", 
                  res$n_groups_custom, res$time_custom_min))
      cat(sprintf("  Total time: %.2f min\n\n", 
                  res$time_hierarchical_min + res$time_custom_min))
      
      results[[nrow(ordering_configs) + seed]] <- res
    }
  }

  # Convert list results to data frame
  comparison <- do.call(rbind, lapply(results, function(x) {
    data.frame(
      ordering_method = x$ordering_method,
      reversed = x$reversed,
      n_groups_hierarchical = x$n_groups_hierarchical,
      n_groups_custom = x$n_groups_custom,
      time_hierarchical_min = x$time_hierarchical_min,
      time_custom_min = x$time_custom_min,
      stringsAsFactors = FALSE
    )
  }))
  rownames(comparison) <- NULL

  # Find best configurations
  best_h_idx <- which.min(comparison$n_groups_hierarchical)
  best_c_idx <- which.min(comparison$n_groups_custom)
  
  # Summary statistics
  cat("========================================\n")
  cat("COMPARISON COMPLETE\n")
  cat("========================================\n")
  cat("Total execution time:", sprintf("%.2f min\n", sum(comparison$time_hierarchical_min + comparison$time_custom_min)))
  cat("\nResults summary:\n")
  cat("  Hierarchical clustering:\n")
  cat(sprintf("    Groups: min=%d, max=%d, mean=%.1f\n", 
              min(comparison$n_groups_hierarchical), 
              max(comparison$n_groups_hierarchical),
              mean(comparison$n_groups_hierarchical)))
  cat(sprintf("    Time: min=%.2f min, max=%.2f min, mean=%.2f min\n",
              min(comparison$time_hierarchical_min),
              max(comparison$time_hierarchical_min),
              mean(comparison$time_hierarchical_min)))
  cat("  Custom clustering:\n")
  cat(sprintf("    Groups: min=%d, max=%d, mean=%.1f\n", 
              min(comparison$n_groups_custom), 
              max(comparison$n_groups_custom),
              mean(comparison$n_groups_custom)))
  cat(sprintf("    Time: min=%.2f min, max=%.2f min, mean=%.2f min\n",
              min(comparison$time_custom_min),
              max(comparison$time_custom_min),
              mean(comparison$time_custom_min)))
  cat("\nBest configurations (minimum groups):\n")
  cat("  Hierarchical clustering:\n")
  cat(sprintf("    Method: %s (reversed=%s)\n", 
              comparison$ordering_method[best_h_idx],
              comparison$reversed[best_h_idx]))
  cat(sprintf("    Groups: %d\n", comparison$n_groups_hierarchical[best_h_idx]))
  cat(sprintf("    Time: %.2f min\n", comparison$time_hierarchical_min[best_h_idx]))
  cat("  Custom clustering:\n")
  cat(sprintf("    Method: %s (reversed=%s)\n", 
              comparison$ordering_method[best_c_idx],
              comparison$reversed[best_c_idx]))
  cat(sprintf("    Groups: %d\n", comparison$n_groups_custom[best_c_idx]))
  cat(sprintf("    Time: %.2f min\n", comparison$time_custom_min[best_c_idx]))
  cat("========================================\n\n")

  comparison
}
