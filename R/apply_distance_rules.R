#' Create Distance Rule Matrix
#'
#' Generates a matrix of spatial distance thresholds for each observation
#' pair, based on their prey classes and temporal separation.
#'
#' @param time_matrix A symmetric matrix of temporal distances (e.g., days)
#'   between observations.
#' @param prey_class A character or factor vector of prey class for each
#'   observation (length must match nrow(time_matrix)).
#' @param dist_rules A data.frame with columns: prey_class1, prey_class2,
#'   temporal_distance_days, distance_threshold_m (distance threshold in
#'   meters). Defaults to the package dataset `lut_distance_rules` if not
#'   supplied.
#' @param max_days The maximum number of days to use for rule lookup (values
#'   above are capped). Default: 11.
#' @return A symmetric matrix of distance thresholds (same dimensions as
#'   time_matrix).
#' @details For each observation pair, looks up the allowed spatial distance
#'   threshold in dist_rules (defaults to `lut_distance_rules` from the
#'   package) based on their prey classes and temporal separation. Diagonal is
#'   set to Inf.
#' @importFrom dplyr filter
#' @export
apply_distance_rules <- function(time_matrix, prey_class, dist_rules = NULL, max_days = 11) {
  # Use package lookup table if not supplied
  if (is.null(dist_rules)) dist_rules <- get("lut_distance_rules", envir = asNamespace("gaupefam"))
  # Input validation
  if (!is.matrix(time_matrix)) stop("time_matrix must be a matrix.")
  if (length(prey_class) != nrow(time_matrix)) stop("prey_class length must match time_matrix dimensions.")
  required_cols <- c(
    "prey_class1", "prey_class2",
    "temporal_distance_days", "distance_threshold_m"
  )
  if (!all(required_cols %in% names(dist_rules))) {
    stop(
      "dist_rules must have columns: prey_class1, prey_class2, ",
      "temporal_distance_days, distance_threshold_m"
    )
  }

  n <- nrow(time_matrix)
  rule_matrix <- time_matrix
  rule_matrix[rule_matrix > max_days] <- max_days

  for (i in seq_len(n)) {
    prey1 <- prey_class[i]
    prey2 <- prey_class
    td <- rule_matrix[i, ]
    dist1 <- vapply(seq_along(prey2), function(x) {
      match_row <- dplyr::filter(
        dist_rules,
        prey_class1 == !!prey1,
        prey_class2 == !!prey2[x],
        temporal_distance_days == !!td[x]
      )
      if (nrow(match_row) == 1) {
        match_row$distance_threshold_m
      } else {
        NA_real_
      }
    }, numeric(1))
    rule_matrix[i, ] <- dist1
  }

  diag(rule_matrix) <- Inf
  if (any(is.na(rule_matrix))) stop("Distance rule matrix contains NA")
  if (!isSymmetric(rule_matrix)) stop("Distance rule matrix is not symmetrical")
  rule_matrix
}
