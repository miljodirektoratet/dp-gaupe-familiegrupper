#' Function | hello
#' @description Print a hello from the package
#' @return Prints message "Hello from 'package-name' !"
#' @export
#'
#' @examples
#' hello()
hello <- function() {
  packagename <- utils::packageName()
  if (is.null(packagename)) {
    packagename <- "<package-name>" # fallback package name
  }
  cat("\U0001f680 Hello from", packagename, "!\n")
}
