#' Reduce Lynx Family Group Count by Reassignment
#'
#' Iteratively attempts to reduce the total number of family groups by reassigning
#' observations to alternative groups while maintaining grouping validity based on
#' spatial-temporal criteria.
#'
#' @param group_assignments An integer vector of initial group assignments for each observation.
#' @param grouping_indicator A logical or numeric matrix where `TRUE` (or 1) indicates
#'   that two observations can be grouped together based on distance/temporal rules.
#' @param distance_matrix A numeric matrix of pairwise distances between observations.
#'
#' @return An integer vector of optimized group assignments with the same length as
#'   the input `group_assignments`. Group IDs may have changed, and the total number
#'   of groups may be reduced compared to the input.
#'
#' @details
#' The algorithm iteratively:
#' 1. Examines each group to see if observations can be reassigned to other groups
#' 2. For single-observation groups, checks if they can join existing groups
#' 3. For multi-observation groups, checks if all members can be reassigned
#' 4. When multiple alternative groups exist, selects the one minimizing total internal distance
#' 5. Continues until no further group reduction is possible
#'
#' The optimization criterion is to minimize the sum of internal distances within
#' all groups while ensuring all observations within each group satisfy the grouping
#' indicator constraints.
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' group_assignments <- c(1, 1, 2, 3, 3)
#' grouping_indicator <- matrix(c(
#'   TRUE, TRUE, TRUE, FALSE, FALSE,
#'   TRUE, TRUE, TRUE, FALSE, FALSE,
#'   TRUE, TRUE, TRUE, FALSE, FALSE,
#'   FALSE, FALSE, FALSE, TRUE, TRUE,
#'   FALSE, FALSE, FALSE, TRUE, TRUE
#' ), nrow = 5, byrow = TRUE)
#' distance_matrix <- matrix(c(
#'   0, 10, 15, 100, 105,
#'   10, 0, 12, 98, 103,
#'   15, 12, 0, 95, 100,
#'   100, 98, 95, 0, 8,
#'   105, 103, 100, 8, 0
#' ), nrow = 5, byrow = TRUE)
#'
#' # Optimize groups
#' optimized <- reduce_group_count(group_assignments, grouping_indicator, distance_matrix)
#' # Expected: Groups 1 and 2 merged since all can group together
#' }
#'
#' @export
reduce_group_count <- function(group_assignments,
                               grouping_indicator,
                               distance_matrix) {
  # Input validation
  if (!is.numeric(group_assignments) && !is.integer(group_assignments)) {
    stop("group_assignments must be a numeric or integer vector")
  }
  if (!is.matrix(grouping_indicator) && !is.data.frame(grouping_indicator)) {
    stop("grouping_indicator must be a matrix or data.frame")
  }
  if (!is.matrix(distance_matrix) && !is.data.frame(distance_matrix)) {
    stop("distance_matrix must be a matrix or data.frame")
  }

  # Convert to appropriate types
  if (is.data.frame(grouping_indicator)) {
    grouping_indicator <- as.matrix(grouping_indicator)
  }
  if (is.data.frame(distance_matrix)) {
    distance_matrix <- as.matrix(distance_matrix)
  }
  if (is.numeric(grouping_indicator)) {
    dim_saved <- dim(grouping_indicator)
    grouping_indicator <- matrix(as.logical(grouping_indicator),
      nrow = dim_saved[1],
      ncol = dim_saved[2]
    )
  }

  # Check dimensions match
  n_obs <- length(group_assignments)
  if (nrow(grouping_indicator) != n_obs || ncol(grouping_indicator) != n_obs) {
    stop("grouping_indicator dimensions must match length of group_assignments")
  }
  if (nrow(distance_matrix) != n_obs || ncol(distance_matrix) != n_obs) {
    stop("distance_matrix dimensions must match length of group_assignments")
  }

  # Initialize tracking of group count changes
  group_counts <- c(Inf, length(unique(group_assignments)))

  # Continue while group count is still decreasing
  while (group_counts[length(group_counts)] != group_counts[length(group_counts) - 1]) {
    # Examine each unique group
    for (current_group_id in unique(group_assignments)) {
      # Find observations in current group
      obs_in_group <- which(group_assignments == current_group_id)

      # Handle single observation groups
      if (length(obs_in_group) == 1) {
        obs_idx <- obs_in_group[1]
        other_obs <- setdiff(seq_len(n_obs), obs_idx)

        # Can this observation join any other group?
        if (!any(grouping_indicator[obs_idx, other_obs])) {
          next # Cannot join any other group
        }

        # Find alternative groups this observation can join
        alternative_candidates <- data.frame(
          ind = obs_idx,
          currentID = current_group_id,
          altID = unique(group_assignments[grouping_indicator[obs_idx, other_obs]])
        )
      } else {
        # Handle multi-observation groups
        other_obs <- setdiff(seq_len(n_obs), obs_in_group)

        # Check if all observations can be reassigned
        give_away_matrix <- grouping_indicator[obs_in_group, other_obs, drop = FALSE]

        # If matrix collapsed to vector and not all can be reassigned, skip
        if (is.null(dim(give_away_matrix)) && !all(give_away_matrix)) {
          next
        }

        # Check each observation can join at least one other group
        if (!all(apply(give_away_matrix, 1, any))) {
          next
        }

        # Find alternative groups for each observation
        alternative_options <- apply(grouping_indicator[obs_in_group, , drop = FALSE], 1, which)
        alternative_candidates <- data.frame(ind = integer(), currentID = integer(), altID = integer())

        for (j in seq_along(obs_in_group)) {
          obs_idx <- obs_in_group[j]
          if (length(alternative_options[[j]]) > 0) {
            alt_ids <- unique(group_assignments[alternative_options[[j]]])
            alternative_candidates <- rbind(
              alternative_candidates,
              data.frame(ind = obs_idx, currentID = current_group_id, altID = alt_ids)
            )
          }
        }
      }

      # Remove self-assignments (current group ID)
      alternative_candidates <- alternative_candidates[alternative_candidates$currentID != alternative_candidates$altID, ]
      if (nrow(alternative_candidates) == 0) {
        next
      }

      # Check if alternative groups can accept the observations
      alternative_candidates$accept <- NA
      for (j in seq_len(nrow(alternative_candidates))) {
        alt_group_obs <- which(group_assignments == alternative_candidates$altID[j])
        alternative_candidates$accept[j] <- all(grouping_indicator[alternative_candidates$ind[j], alt_group_obs])
      }

      # Check if all observations in current group can be reassigned
      accepted_obs <- unique(alternative_candidates[, c("ind", "currentID")])
      accepted_obs$accept <- accepted_obs$ind %in% alternative_candidates$ind[alternative_candidates$accept]

      # Only proceed if all observations can be reassigned
      if (!all(accepted_obs$accept) || !all(obs_in_group %in% accepted_obs$ind)) {
        next
      }

      # Filter to accepted alternatives
      alternative_candidates <- alternative_candidates[alternative_candidates$accept, c("ind", "currentID", "altID", "accept")]
      alternative_candidates <- unique(alternative_candidates)

      # For observations with multiple alternatives, choose best based on distance
      for (obs_idx in unique(alternative_candidates$ind)) {
        obs_alternatives <- alternative_candidates[alternative_candidates$ind == obs_idx, ]

        if (nrow(obs_alternatives) > 1) {
          # Evaluate each alternative based on total internal distance
          alt_eval <- data.frame(
            ind = obs_alternatives$ind,
            ID = obs_alternatives$altID,
            distW = NA_real_,
            distWO = NA_real_
          )

          for (k in seq_len(nrow(alt_eval))) {
            # Distance WITH the observation added to alternative group
            group_with <- c(which(group_assignments == alt_eval$ID[k]), alt_eval$ind[k])
            group_with <- unique(group_with)
            dist_mat_with <- distance_matrix[group_with, group_with, drop = FALSE]
            dist_mat_with[upper.tri(dist_mat_with)] <- 0
            alt_eval$distW[k] <- sum(dist_mat_with)

            # Distance WITHOUT the observation (just the alternative group)
            group_without <- setdiff(group_with, alt_eval$ind[k])
            if (length(group_without) > 1) {
              dist_mat_without <- distance_matrix[group_without, group_without, drop = FALSE]
              dist_mat_without[upper.tri(dist_mat_without)] <- 0
              alt_eval$distWO[k] <- sum(dist_mat_without)
            } else {
              alt_eval$distWO[k] <- 0
            }
          }

          # Calculate criterion: total distance with this assignment
          alt_eval$criteria <- alt_eval$distW
          for (k in seq_len(nrow(alt_eval))) {
            alt_eval$criteria[k] <- alt_eval$distW[k] + sum(alt_eval$distWO[-k])
          }

          # Keep only the best alternative
          best_alt <- alt_eval[which.min(alt_eval$criteria), ]
          alternative_candidates <- alternative_candidates[
            !(alternative_candidates$ind == obs_idx & alternative_candidates$altID != best_alt$ID),
          ]
        }
      }

      # Apply reassignments
      group_assignments[alternative_candidates$ind] <- alternative_candidates$altID
    }

    # Track group count
    group_counts <- c(group_counts, length(unique(group_assignments)))
  }

  return(group_assignments)
}
