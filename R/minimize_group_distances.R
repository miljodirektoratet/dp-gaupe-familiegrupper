#' Minimize Lynx Family Group Internal Distances
#'
#' Iteratively refines group assignments by reassigning each observation to the
#' group that minimizes the sum of internal distances across all groups. This
#' optimization improves group compactness after initial clustering.
#'
#' @param group_assignments An integer vector of initial group assignments for each observation.
#' @param distance_matrix A numeric matrix of pairwise distances between observations.
#' @param grouping_indicator A logical or numeric matrix where `TRUE` (or 1) indicates
#'   that two observations can be grouped together based on distance/temporal rules.
#'
#' @return An integer vector of optimized group assignments with the same length as
#'   the input `group_assignments`. Group IDs remain the same, but observations may
#'   be reassigned to minimize total internal distances.
#'
#' @details
#' The algorithm iteratively processes each observation:
#' 1. Identifies all valid alternative groups the observation could join
#' 2. For each alternative, calculates the total internal distance if the observation were reassigned
#' 3. Selects the group assignment that minimizes the sum of all internal distances
#' 4. Continues until no further improvements are possible (convergence)
#'
#' This function is typically run after `reduce_group_count()` to fine-tune the
#' quality of group assignments by making them more spatially compact.
#'
#' The optimization criterion is the sum of all pairwise distances within each group,
#' summed across all groups in the dataset.
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' group_assignments <- c(1, 1, 2, 2, 2)
#' distance_matrix <- matrix(c(
#'   0, 10, 50, 55, 52,
#'   10, 0, 48, 53, 50,
#'   50, 48, 0, 8, 12,
#'   55, 53, 8, 0, 10,
#'   52, 50, 12, 10, 0
#' ), nrow = 5, byrow = TRUE)
#' grouping_indicator <- matrix(TRUE, 5, 5)
#'
#' # Optimize distances
#' optimized <- minimize_group_distances(group_assignments, distance_matrix, grouping_indicator)
#' }
#'
#' @export
minimize_group_distances <- function(group_assignments,
                                     distance_matrix,
                                     grouping_indicator) {
  # Input validation
  if (!is.numeric(group_assignments) && !is.integer(group_assignments)) {
    stop("group_assignments must be a numeric or integer vector")
  }
  if (!is.matrix(distance_matrix) && !is.data.frame(distance_matrix)) {
    stop("distance_matrix must be a matrix or data.frame")
  }
  if (!is.matrix(grouping_indicator) && !is.data.frame(grouping_indicator)) {
    stop("grouping_indicator must be a matrix or data.frame")
  }

  # Convert to appropriate types
  if (is.data.frame(distance_matrix)) {
    distance_matrix <- as.matrix(distance_matrix)
  }
  if (is.data.frame(grouping_indicator)) {
    grouping_indicator <- as.matrix(grouping_indicator)
  }
  if (is.numeric(grouping_indicator)) {
    dim_saved <- dim(grouping_indicator)
    grouping_indicator <- matrix(as.logical(grouping_indicator),
      nrow = dim_saved[1],
      ncol = dim_saved[2]
    )
  }

  # Check dimensions
  n_obs <- length(group_assignments)
  if (nrow(distance_matrix) != n_obs || ncol(distance_matrix) != n_obs) {
    stop("distance_matrix dimensions must match length of group_assignments")
  }
  if (nrow(grouping_indicator) != n_obs || ncol(grouping_indicator) != n_obs) {
    stop("grouping_indicator dimensions must match length of group_assignments")
  }

  # Track assignment changes
  assignment_history <- data.frame(ind = seq_len(n_obs), id = group_assignments)

  # Iterate until convergence (no changes)
  while (!all(assignment_history[, ncol(assignment_history)] == assignment_history[, ncol(assignment_history) - 1])) {
    # Process each observation
    for (i in seq_len(n_obs)) {
      current_group <- group_assignments[i]

      # Find observations this one can group with
      compatible_obs <- which(grouping_indicator[i, ])
      potential_groups <- unique(group_assignments[compatible_obs])

      # If only one group available (current group), skip
      if (length(potential_groups) == 1) {
        next
      }

      # Check which alternative groups can accept this observation
      valid_alternatives <- integer()
      for (group_id in potential_groups) {
        group_members <- which(group_assignments == group_id)
        # Check if observation is compatible with all members of this group
        if (all(grouping_indicator[i, group_members])) {
          valid_alternatives <- c(valid_alternatives, group_id)
        }
      }

      # If no valid alternatives (or only current group), skip
      if (length(valid_alternatives) <= 1) {
        next
      }

      # Evaluate each alternative based on total internal distance
      alt_eval <- data.frame(
        groupID = valid_alternatives,
        distW = NA_real_,
        distWO = NA_real_,
        criteria = NA_real_
      )

      for (j in seq_len(nrow(alt_eval))) {
        alt_group <- alt_eval$groupID[j]

        # Calculate distance WITH observation in this group
        group_with <- unique(c(which(group_assignments == alt_group), i))
        dist_mat_with <- distance_matrix[group_with, group_with, drop = FALSE]
        dist_mat_with[upper.tri(dist_mat_with)] <- 0
        alt_eval$distW[j] <- sum(dist_mat_with)

        # Calculate distance WITHOUT observation in this group
        group_without <- setdiff(group_with, i)
        if (length(group_without) > 1) {
          dist_mat_without <- distance_matrix[group_without, group_without, drop = FALSE]
          dist_mat_without[upper.tri(dist_mat_without)] <- 0
          alt_eval$distWO[j] <- sum(dist_mat_without)
        } else {
          alt_eval$distWO[j] <- 0
        }
      }

      # Calculate total criterion: distance with this assignment + sum of distances without for other groups
      for (j in seq_len(nrow(alt_eval))) {
        alt_eval$criteria[j] <- alt_eval$distW[j] + sum(alt_eval$distWO[-j])
      }

      # Assign to group with minimum total distance
      best_group <- alt_eval$groupID[which.min(alt_eval$criteria)]
      group_assignments[i] <- best_group
    }

    # Track changes
    assignment_history <- cbind(assignment_history, id = group_assignments)
  }

  group_assignments
}
