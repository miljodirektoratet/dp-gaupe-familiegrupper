#' Hierarchical Clustering for Lynx Family Group Assignment
#'
#' Performs hierarchical clustering on a grouping index matrix to assign observations
#' to family groups based on spatial and temporal distance relationships.
#'
#' @param grouping_index A numeric matrix where values represent the ratio of actual
#'   distance to distance rule threshold. Values < 1 indicate observations that should
#'   be grouped together; values > 1 indicate observations that should be separated.
#' @param hclust_poly A numeric exponent applied to the grouping index before clustering.
#'   Higher values increase separation between groups. Default is 1 (no transformation).
#' @param cut_height The height at which to cut the dendrogram to form clusters.
#'   Default is 1, which groups observations with `grouping_index^hclust_poly < 1`.
#'
#' @return An integer vector of cluster assignments, with the same length as the
#'   number of rows/columns in `grouping_index`.
#'
#' @details
#' The function:
#' 1. Applies a power transformation to the grouping index: `grouping_index^hclust_poly`
#' 2. Converts the transformed matrix to a distance object
#' 3. Performs hierarchical clustering using complete linkage (default)
#' 4. Cuts the dendrogram at the specified height to create cluster assignments
#'
#' The grouping index is typically calculated as `distance_matrix / distance_rule_matrix`,
#' where distance_rule_matrix contains the maximum allowed distances for observation pairs
#' based on prey class and temporal separation.
#'
#' @examples
#' \dontrun{
#' # Create sample grouping index (ratio of actual to allowed distance)
#' grouping_index <- matrix(c(
#'   0.5, 0.8, 1.5,
#'   0.8, 0.5, 1.2,
#'   1.5, 1.2, 0.5
#' ), nrow = 3, byrow = TRUE)
#'
#' # Perform clustering
#' clusters <- cluster_hierarchical(grouping_index, hclust_poly = 1)
#' }
#'
#' @importFrom stats hclust as.dist cutree
#' @export
cluster_hierarchical <- function(grouping_index,
                                 hclust_poly = 1,
                                 cut_height = 1) {
  # Input validation
  if (!is.matrix(grouping_index) && !is.data.frame(grouping_index)) {
    stop("grouping_index must be a matrix or data.frame")
  }
  if (!is.numeric(hclust_poly) || length(hclust_poly) != 1) {
    stop("hclust_poly must be a single numeric value")
  }
  if (!is.numeric(cut_height) || length(cut_height) != 1 || cut_height <= 0) {
    stop("cut_height must be a single positive numeric value")
  }

  # Convert to matrix if needed
  if (is.data.frame(grouping_index)) {
    grouping_index <- as.matrix(grouping_index)
  }

  # Perform hierarchical clustering
  transformed_index <- grouping_index^hclust_poly
  distance_object <- stats::as.dist(transformed_index)
  hclust_result <- stats::hclust(distance_object)

  # Cut dendrogram at specified height
  cluster_assignments <- stats::cutree(hclust_result, h = cut_height)

  cluster_assignments
}
