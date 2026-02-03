#' Custom Clustering for Lynx Family Group Assignment
#'
#' Performs custom clustering based on a binary grouping indicator matrix.
#' Assigns observations to family groups by ensuring all observations within
#' a group can be connected to each other (complete linkage criterion).
#'
#' @param grouping_indicator A logical or numeric matrix where `TRUE` (or 1)
#'   indicates that two observations can be grouped together based on spatial
#'   and temporal criteria. The matrix should be symmetric with diagonal values
#'   representing self-grouping (typically `TRUE`).
#'
#' @return An integer vector of cluster assignments, with the same length as the
#'   number of rows/columns in `grouping_indicator`. Each unique integer represents
#'   a distinct family group.
#'
#' @details
#' The algorithm iteratively processes each observation:
#' 1. If an observation already has a group assignment, skip it
#' 2. Find all observations that can potentially group with it
#' 3. Check if all potential group members can group with each other (complete linkage)
#' 4. If not, iteratively remove the observation with the most conflicts
#' 5. Assign a new group ID to the final valid group
#'
#' This approach ensures that within each group, every observation can be paired
#' with every other observation according to the grouping criteria (typically
#' spatial distance and temporal proximity rules).
#'
#' @examples
#' \dontrun{
#' # Create a binary grouping indicator matrix
#' # TRUE means observations can be grouped together
#' grouping_indicator <- matrix(c(
#'   TRUE, TRUE, FALSE, FALSE,
#'   TRUE, TRUE, FALSE, FALSE,
#'   FALSE, FALSE, TRUE, TRUE,
#'   FALSE, FALSE, TRUE, TRUE
#' ), nrow = 4, byrow = TRUE)
#'
#' # Perform clustering
#' clusters <- cluster_custom(grouping_indicator)
#' # Expected: c(1, 1, 2, 2) - two groups of two observations each
#' }
#'
#' @export
cluster_custom <- function(grouping_indicator) {
  # Input validation
  if (!is.matrix(grouping_indicator) && !is.data.frame(grouping_indicator)) {
    stop("grouping_indicator must be a matrix or data.frame")
  }

  # Convert to matrix if needed
  if (is.data.frame(grouping_indicator)) {
    grouping_indicator <- as.matrix(grouping_indicator)
  }

  # Check dimensions before conversion
  if (nrow(grouping_indicator) != ncol(grouping_indicator)) {
    stop("grouping_indicator must be a square matrix")
  }

  # Convert to logical if numeric, preserving matrix structure
  if (is.numeric(grouping_indicator)) {
    dim_saved <- dim(grouping_indicator)
    grouping_indicator <- matrix(as.logical(grouping_indicator),
      nrow = dim_saved[1],
      ncol = dim_saved[2]
    )
  }

  # Initialize group assignments
  n_obs <- nrow(grouping_indicator)
  group_assignments <- rep(NA_integer_, times = n_obs)
  next_group_id <- 1L

  # Process each observation
  for (i in seq_len(n_obs)) {
    # Skip if already assigned
    if (!is.na(group_assignments[i])) {
      next
    }

    # Find potential group members (observations that can group with i)
    potential_group <- which(grouping_indicator[i, ])

    # Check if all potential members can group with each other (complete linkage)
    if (all(grouping_indicator[potential_group, potential_group])) {
      # All can group together - assign group ID
      group_assignments[potential_group] <- next_group_id
      next_group_id <- next_group_id + 1L
    } else {
      # Iteratively remove observations with most conflicts until complete linkage achieved
      while (!all(grouping_indicator[potential_group, potential_group])) {
        # Count conflicts for each observation in potential group
        submatrix <- grouping_indicator[potential_group, potential_group]
        n_conflicts <- apply(submatrix, 1, function(x) sum(!x))

        # Remove observation with most conflicts
        exclude_idx <- which.max(n_conflicts)
        potential_group <- potential_group[-exclude_idx]
      }

      # Assign group ID to remaining valid group
      if (length(potential_group) > 0) {
        group_assignments[potential_group] <- next_group_id
        next_group_id <- next_group_id + 1L
      }
    }
  }

  group_assignments
}
