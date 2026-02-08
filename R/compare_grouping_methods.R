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
#' @param clustering_methods Character vector. Which clustering methods to test.
#'   Options: c("both"), c("hierarchical"), c("custom"), or c("hierarchical", "custom").
#'   Default is c("both"). Use single method to reduce runtime by ~50%.
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
#' @param verbose Logical. Print progress after each configuration? Default TRUE.
#'   When parallel=TRUE, prints batch summaries instead of individual configs.
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
#' # Test only custom clustering (faster)
#' comparison_custom <- compare_grouping_methods(
#'   data = lynx_family_test_data,
#'   clustering_methods = "custom",
#'   optimize_group_count = FALSE,
#'   optimize_distances = FALSE,
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
                                     clustering_methods = c("both"),
                                     optimize_group_count = TRUE,
                                     optimize_distances = TRUE,
                                     hclust_poly = 1,
                                     group_col = "group_id",
                                     parallel = TRUE,
                                     n_cores = NULL,
                                     verbose = TRUE) {
  # Input validation
  if (!inherits(data, "sf")) {
    stop("'data' must be an sf object")
  }

  required_cols <- c("rovbase_id", "datotid_fra", "datotid_til", "byttedyr")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("'data' is missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Validate clustering_methods parameter
  if ("both" %in% clustering_methods) {
    test_hierarchical <- TRUE
    test_custom <- TRUE
  } else {
    test_hierarchical <- "hierarchical" %in% clustering_methods
    test_custom <- "custom" %in% clustering_methods
  }
  
  if (!test_hierarchical && !test_custom) {
    stop("'clustering_methods' must be 'both', 'hierarchical', 'custom', or c('hierarchical', 'custom')")
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
      if (verbose) cat("Parallel processing enabled with", n_cores, "cores\n")
    }
  }

  # Define all ordering strategies to test
  ordering_configs <- expand.grid(
    method = c("time", "pca1", "pca2", "north-south", "east-west"),
    reversed = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  # Calculate total number of tests
  n_standard_configs <- nrow(ordering_configs)
  n_random_configs <- 5
  total_configs <- n_standard_configs + n_random_configs
  current_config <- 0
  
  methods_to_test <- c()
  if (test_hierarchical) methods_to_test <- c(methods_to_test, "hierarchical")
  if (test_custom) methods_to_test <- c(methods_to_test, "custom")

  if (verbose) {
    cat("\n========================================\n")
    cat("GROUPING METHOD COMPARISON\n")
    cat("========================================\n")
    cat("Total configurations to test:", total_configs, "\n")
    cat("  - Standard orderings:", n_standard_configs, "\n")
    cat("  - Random orderings:", n_random_configs, "\n")
    cat("Clustering methods:", paste(methods_to_test, collapse = ", "), "\n")
    cat("Total grouping runs:", total_configs * length(methods_to_test), "\n")
    cat("========================================\n\n")
  }

  # Function to test a single configuration
  test_config <- function(i, config, is_random = FALSE, seed = NULL) {
    if (is_random) {
      set.seed(seed)
      config_name <- paste0("random_seed", seed)
    } else {
      config_name <- sprintf("%s (reversed=%s)", config$method, config$reversed)
    }
    
    # Initialize result variables
    n_groups_h <- NA
    time_h_min <- NA
    n_groups_c <- NA
    time_c_min <- NA
    
    # Hierarchical clustering (if requested)
    if (test_hierarchical) {
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
    }

    # Custom clustering (if requested)
    if (test_custom) {
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
    }

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
                                   "ordering_configs", "base_path", "test_hierarchical", 
                                   "test_custom"),
                            envir = environment())
    
    # Load the entire package on each worker
    parallel::clusterEvalQ(cl, {
      library(sf)
      library(dplyr)
      
      # Try to load package (production: library, development: devtools::load_all)
      if (requireNamespace("gaupefam", quietly = TRUE)) {
        # Package is installed - use it (production)
        library(gaupefam)
      } else if (requireNamespace("devtools", quietly = TRUE)) {
        # Development mode - load from source
        devtools::load_all(base_path)
      } else {
        stop("Package 'gaupefam' not found. Install it or ensure devtools is available for development.")
      }
    })
    
    if (verbose) cat("Running standard orderings in parallel...\n")
    results_standard <- parallel::parLapply(cl, seq_len(nrow(ordering_configs)), function(i) {
      test_config(i, ordering_configs[i, ], is_random = FALSE)
    })
    
    # Print summary after standard configs
    if (verbose) {
      cat("Standard orderings complete. Current standings:\n")
      temp_df <- do.call(rbind, lapply(results_standard, function(x) {
        data.frame(
          ordering_method = x$ordering_method,
          reversed = x$reversed,
          n_groups_hierarchical = x$n_groups_hierarchical,
          n_groups_custom = x$n_groups_custom,
          stringsAsFactors = FALSE
        )
      }))
      
      if (test_hierarchical && !all(is.na(temp_df$n_groups_hierarchical))) {
        best_h <- which.min(temp_df$n_groups_hierarchical)
        cat(sprintf("  Best hierarchical: %s (reversed=%s) with %d groups\n",
                    temp_df$ordering_method[best_h],
                    temp_df$reversed[best_h],
                    temp_df$n_groups_hierarchical[best_h]))
      }
      
      if (test_custom && !all(is.na(temp_df$n_groups_custom))) {
        best_c <- which.min(temp_df$n_groups_custom)
        cat(sprintf("  Best custom: %s (reversed=%s) with %d groups\n",
                    temp_df$ordering_method[best_c],
                    temp_df$reversed[best_c],
                    temp_df$n_groups_custom[best_c]))
      }
      cat("\n")
    }
    
    if (verbose) cat("Running random orderings in parallel...\n")
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
      
      if (verbose) {
        cat(sprintf("\n[%d/%d] Testing: %s (reversed=%s)\n", 
                    current_config, total_configs, config$method, config$reversed))
        cat("----------------------------------------\n")
      }
      
      res <- test_config(i, config, is_random = FALSE)
      
      if (verbose) {
        if (test_hierarchical && !is.na(res$n_groups_hierarchical)) {
          cat(sprintf("  Hierarchical: %d groups (%.2f min)\n", 
                      res$n_groups_hierarchical, res$time_hierarchical_min))
        }
        if (test_custom && !is.na(res$n_groups_custom)) {
          cat(sprintf("  Custom: %d groups (%.2f min)\n", 
                      res$n_groups_custom, res$time_custom_min))
        }
        
        # Show running best
        temp_results <- results
        temp_results[[length(temp_results) + 1]] <- res
        temp_df <- do.call(rbind, lapply(temp_results, function(x) {
          data.frame(
            ordering_method = x$ordering_method,
            n_groups_hierarchical = x$n_groups_hierarchical,
            n_groups_custom = x$n_groups_custom,
            stringsAsFactors = FALSE
          )
        }))
        
        cat("  Running best so far:\n")
        if (test_hierarchical && !all(is.na(temp_df$n_groups_hierarchical))) {
          min_h <- min(temp_df$n_groups_hierarchical, na.rm = TRUE)
          count_h <- sum(temp_df$n_groups_hierarchical == min_h, na.rm = TRUE)
          cat(sprintf("    Hierarchical: %d groups (%d config%s)\n", 
                      min_h, count_h, ifelse(count_h > 1, "s", "")))
        }
        if (test_custom && !all(is.na(temp_df$n_groups_custom))) {
          min_c <- min(temp_df$n_groups_custom, na.rm = TRUE)
          count_c <- sum(temp_df$n_groups_custom == min_c, na.rm = TRUE)
          cat(sprintf("    Custom: %d groups (%d config%s)\n", 
                      min_c, count_c, ifelse(count_c > 1, "s", "")))
        }
      }
      
      results[[i]] <- res
    }

    # Test random orderings (sequential)
    for (seed in 1:5) {
      current_config <- current_config + 1
      
      if (verbose) {
        cat(sprintf("\n[%d/%d] Testing: random_seed%d\n", 
                    current_config, total_configs, seed))
        cat("----------------------------------------\n")
      }
      
      res <- test_config(seed, NULL, is_random = TRUE, seed = seed)
      
      if (verbose) {
        if (test_hierarchical && !is.na(res$n_groups_hierarchical)) {
          cat(sprintf("  Hierarchical: %d groups (%.2f min)\n", 
                      res$n_groups_hierarchical, res$time_hierarchical_min))
        }
        if (test_custom && !is.na(res$n_groups_custom)) {
          cat(sprintf("  Custom: %d groups (%.2f min)\n", 
                      res$n_groups_custom, res$time_custom_min))
        }
        
        # Show running best
        temp_results <- results
        temp_results[[length(temp_results) + 1]] <- res
        temp_df <- do.call(rbind, lapply(temp_results, function(x) {
          data.frame(
            ordering_method = x$ordering_method,
            n_groups_hierarchical = x$n_groups_hierarchical,
            n_groups_custom = x$n_groups_custom,
            stringsAsFactors = FALSE
          )
        }))
        
        cat("  Running best so far:\n")
        if (test_hierarchical && !all(is.na(temp_df$n_groups_hierarchical))) {
          min_h <- min(temp_df$n_groups_hierarchical, na.rm = TRUE)
          count_h <- sum(temp_df$n_groups_hierarchical == min_h, na.rm = TRUE)
          cat(sprintf("    Hierarchical: %d groups (%d config%s)\n", 
                      min_h, count_h, ifelse(count_h > 1, "s", "")))
        }
        if (test_custom && !all(is.na(temp_df$n_groups_custom))) {
          min_c <- min(temp_df$n_groups_custom, na.rm = TRUE)
          count_c <- sum(temp_df$n_groups_custom == min_c, na.rm = TRUE)
          cat(sprintf("    Custom: %d groups (%d config%s)\n", 
                      min_c, count_c, ifelse(count_c > 1, "s", "")))
        }
      }
      
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
  if (test_hierarchical && any(!is.na(comparison$n_groups_hierarchical))) {
    best_h_idx <- which.min(comparison$n_groups_hierarchical)
  } else {
    best_h_idx <- NULL
  }
  
  if (test_custom && any(!is.na(comparison$n_groups_custom))) {
    best_c_idx <- which.min(comparison$n_groups_custom)
  } else {
    best_c_idx <- NULL
  }
  
  # Summary statistics
  if (verbose) {
    cat("\n========================================\n")
    cat("COMPARISON COMPLETE\n")
    cat("========================================\n")
    
    total_time <- sum(comparison$time_hierarchical_min, comparison$time_custom_min, na.rm = TRUE)
    cat("Total execution time:", sprintf("%.2f min\n", total_time))
    
    if (test_hierarchical && !is.null(best_h_idx)) {
      cat("\nHierarchical clustering results:\n")
      cat(sprintf("  Groups: min=%d, max=%d, mean=%.1f\n", 
                  min(comparison$n_groups_hierarchical, na.rm = TRUE), 
                  max(comparison$n_groups_hierarchical, na.rm = TRUE),
                  mean(comparison$n_groups_hierarchical, na.rm = TRUE)))
      cat(sprintf("  Time: min=%.2f min, max=%.2f min, mean=%.2f min\n",
                  min(comparison$time_hierarchical_min, na.rm = TRUE),
                  max(comparison$time_hierarchical_min, na.rm = TRUE),
                  mean(comparison$time_hierarchical_min, na.rm = TRUE)))
      cat("  Best configuration (minimum groups):\n")
      cat(sprintf("    Method: %s (reversed=%s)\n", 
                  comparison$ordering_method[best_h_idx],
                  comparison$reversed[best_h_idx]))
      cat(sprintf("    Groups: %d\n", comparison$n_groups_hierarchical[best_h_idx]))
      cat(sprintf("    Time: %.2f min\n", comparison$time_hierarchical_min[best_h_idx]))
      
      # Count how many configs achieved this minimum
      min_groups_h <- comparison$n_groups_hierarchical[best_h_idx]
      count_min_h <- sum(comparison$n_groups_hierarchical == min_groups_h, na.rm = TRUE)
      if (count_min_h > 1) {
        cat(sprintf("    (%d configurations achieved %d groups)\n", count_min_h, min_groups_h))
      }
    }
    
    if (test_custom && !is.null(best_c_idx)) {
      cat("\nCustom clustering results:\n")
      cat(sprintf("  Groups: min=%d, max=%d, mean=%.1f\n", 
                  min(comparison$n_groups_custom, na.rm = TRUE), 
                  max(comparison$n_groups_custom, na.rm = TRUE),
                  mean(comparison$n_groups_custom, na.rm = TRUE)))
      cat(sprintf("  Time: min=%.2f min, max=%.2f min, mean=%.2f min\n",
                  min(comparison$time_custom_min, na.rm = TRUE),
                  max(comparison$time_custom_min, na.rm = TRUE),
                  mean(comparison$time_custom_min, na.rm = TRUE)))
      cat("  Best configuration (minimum groups):\n")
      cat(sprintf("    Method: %s (reversed=%s)\n", 
                  comparison$ordering_method[best_c_idx],
                  comparison$reversed[best_c_idx]))
      cat(sprintf("    Groups: %d\n", comparison$n_groups_custom[best_c_idx]))
      cat(sprintf("    Time: %.2f min\n", comparison$time_custom_min[best_c_idx]))
      
      # Count how many configs achieved this minimum
      min_groups_c <- comparison$n_groups_custom[best_c_idx]
      count_min_c <- sum(comparison$n_groups_custom == min_groups_c, na.rm = TRUE)
      if (count_min_c > 1) {
        cat(sprintf("    (%d configurations achieved %d groups)\n", count_min_c, min_groups_c))
      }
    }
    
    cat("========================================\n\n")
  }

  comparison
}
