#' Group Lynx Observations into Family Groups
#'
#' Groups lynx observations into family groups based on spatiotemporal proximity
#' and ecological distance rules. Uses a pipeline of clustering, optimization,
#' and refinement steps.
#'
#' @param data An sf object containing lynx observations with columns:
#'   \itemize{
#'     \item rovbase_id - Unique observation identifier
#'     \item datotid_fra - Activity start datetime
#'     \item datotid_til - Activity end datetime
#'     \item byttedyr - Prey class category
#'     \item geometry - Spatial point geometry
#'   }
#' @param clustering_method Character. Clustering algorithm to use. One of:
#'   \itemize{
#'     \item "cluster_hierarchical" - Hierarchical clustering
#'     \item "cluster_custom" - Custom complete-linkage clustering
#'   }
#' @param ordering_method Character. Method to order observations before clustering.
#'   One of: "time", "pca1", "pca2", "north-south", "east-west", "random".
#'   Default is "time".
#' @param reversed Logical. If TRUE, reverses the ordering direction. Default FALSE.
#' @param optimize_group_count Logical. If TRUE, attempts to reduce total number
#'   of groups through reassignment. Default TRUE.
#' @param optimize_distances Logical. If TRUE, minimizes internal group distances
#'   through iterative reassignment. Default TRUE.
#' @param hclust_poly Numeric. Polynomial exponent for hierarchical clustering.
#'   Only used when clustering_method = "cluster_hierarchical". Default 1.
#' @param group_col Character. Name of the group column to create in the output.
#'   Default is "gruppe_id" (Norwegian naming convention). Can be set to "group_id"
#'   or any custom name.
#'
#' @return An sf object identical to input data with added column specified by
#'   \code{group_col} (default "gruppe_id"). Contains integer group assignments.
#'   The function validates that the column was created successfully and will
#'   throw an error if it fails. Warnings are issued if all values are NA (no
#'   groups formed) or if the data type is unexpected.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(gaupefam)
#'
#' # Basic grouping with defaults
#' grouped <- group_lynx_families(
#'   data = lynx_family_test_data,
#'   clustering_method = "cluster_custom"
#' )
#'
#' # Custom configuration
#' grouped <- group_lynx_families(
#'   data = lynx_family_test_data,
#'   clustering_method = "cluster_hierarchical",
#'   ordering_method = "pca1",
#'   reversed = FALSE,
#'   optimize_group_count = TRUE,
#'   optimize_distances = TRUE,
#'   hclust_poly = 1.5
#' )
#'
#' # Check results
#' table(grouped$group_id) # Observations per group
#' }
group_lynx_families <- function(data,
                                clustering_method,
                                ordering_method = "time",
                                reversed = FALSE,
                                optimize_group_count = TRUE,
                                optimize_distances = TRUE,
                                hclust_poly = 1,
                                group_col = "gruppe_id") {
  # === Input Validation ===
  if (!inherits(data, "sf")) {
    stop("'data' must be an sf object")
  }

  required_cols <- c("rovbase_id", "datotid_fra", "datotid_til", "byttedyr")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("'data' is missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  if (!clustering_method %in% c("cluster_hierarchical", "cluster_custom")) {
    stop("'clustering_method' must be 'cluster_hierarchical' or 'cluster_custom'")
  }

  valid_orders <- c("time", "pca1", "pca2", "north-south", "east-west", "random")
  if (!ordering_method %in% valid_orders) {
    stop("'ordering_method' must be one of: ", paste(valid_orders, collapse = ", "))
  }

  if (!is.logical(reversed) || !is.logical(optimize_group_count) || !is.logical(optimize_distances)) {
    stop("'reversed', 'optimize_group_count', and 'optimize_distances' must be logical")
  }

  if (!is.numeric(hclust_poly) || hclust_poly <= 0) {
    stop("'hclust_poly' must be a positive number")
  }

  # === Pipeline Step 1: Order Observations ===
  data_ordered <- order_observations(
    data = data,
    reversed = reversed,
    which_order = ordering_method,
    time_column = "datotid_fra"
  )

  # === Pipeline Step 2: Create Temporal Distance Matrix ===
  time_matrix <- create_time_matrix(
    activity_from = data_ordered$datotid_fra,
    activity_to = data_ordered$datotid_til
  )

  # === Pipeline Step 3: Create Spatial Distance Matrix ===
  distance_matrix <- create_distance_matrix(
    geometry = data_ordered$geometry
  )

  # === Pipeline Step 4: Apply Ecological Distance Rules ===
  distance_rule_matrix <- apply_distance_rules(
    time_matrix = time_matrix,
    prey_class = data_ordered$byttedyr
  )

  # === Pipeline Step 5: Create Grouping Matrices ===
  # Binary indicator: can these observations be grouped?
  grouping_indicator <- distance_rule_matrix > distance_matrix

  # Relative index: how far over/under the distance threshold?
  grouping_index <- distance_matrix / distance_rule_matrix

  # === Pipeline Step 6: Cluster Observations ===
  if (clustering_method == "cluster_hierarchical") {
    group_assignments <- cluster_hierarchical(
      grouping_index = grouping_index,
      hclust_poly = hclust_poly
    )
  } else { # cluster_custom
    group_assignments <- cluster_custom(
      grouping_indicator = grouping_indicator
    )
  }

  # === Pipeline Step 7: Optimize Group Count (Optional) ===
  if (optimize_group_count) {
    group_assignments <- reduce_group_count(
      group_assignments = group_assignments,
      grouping_indicator = grouping_indicator,
      distance_matrix = distance_matrix
    )
  }

  # === Pipeline Step 8: Optimize Internal Distances (Optional) ===
  if (optimize_distances) {
    group_assignments <- minimize_group_distances(
      group_assignments = group_assignments,
      distance_matrix = distance_matrix,
      grouping_indicator = grouping_indicator
    )
  }

  # === Return Enriched Data ===
  data_ordered[[group_col]] <- group_assignments

  # === Validate Output ===
  # Check that the column was created successfully
  if (!group_col %in% names(data_ordered)) {
    stop(
      "Failed to create output column '", group_col, "'. ",
      "Available columns: ", paste(names(data_ordered), collapse = ", ")
    )
  }

  # Check that group assignments are valid
  if (all(is.na(data_ordered[[group_col]]))) {
    warning(
      "All group assignments are NA. This may indicate that no observations ",
      "could be grouped based on the distance rules and clustering method."
    )
  }

  # Check that group_col contains expected data type
  if (!is.integer(data_ordered[[group_col]]) && !all(is.na(data_ordered[[group_col]]))) {
    warning(
      "Column '", group_col, "' is not integer type. ",
      "Expected integer group IDs, got: ", class(data_ordered[[group_col]])[1]
    )
  }

  data_ordered
}
