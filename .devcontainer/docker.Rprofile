# source("renv/activate.R")
# WD must be the project directory in RSTUDIO user dir
setwd("/home/rstudio/workspace")
options(startup.verbatim = FALSE)
suppressPackageStartupMessages({
  if (file.exists("/home/rstudio/workspace/renv/activate.R")) {
    source("/home/rstudio/workspace/renv/activate.R")
  }
})

# Welcome message
cat("Docker | R Development Environment\n")
cat("RENV_PROJECT:", Sys.getenv("RENV_PROJECT"), "\n")
cat("R version:", R.version.string, "\n")
if (requireNamespace("renv", quietly = TRUE)) {
  tryCatch(
    {
      cat("renv version:", as.character(utils::packageVersion("renv")), "\n")
    },
    error = function(e) {
      # Silently skip if utils isn't loaded yet
    }
  )
}

# configure
options(repos = c(
  "CRAN" = "https://cloud.r-project.org",
  "R-Universe" = "https://apache.r-universe.dev" # necessary for arrow package
))

# Renv status (with dev = TRUE)
if (requireNamespace("renv", quietly = TRUE) && interactive()) {
  renv::status(dev = TRUE)
}

# Print RENV_PROJECT, RENV_PATHS_LIBRARY, RENV_PATHS_CACHE
if (requireNamespace("renv", quietly = TRUE)) {
  cat("renv library:", renv::paths$library(), "\n")
  cat("renv global cache:", renv::paths$cache(), "\n")
}

cache_path <- renv::paths$cache()
files <- list.files(
  cache_path,
  full.names = TRUE
)
# print(files)
# sizes <- file.info(files)$size
# total_size_bytes <- sum(sizes, na.rm = TRUE)
# cat("Total size of renv cache (MB): ")
# print(total_size_bytes / (1024^2))

# Load the package in development mode
# if (requireNamespace("devtools", quietly = TRUE) && file.exists("DESCRIPTION")) {
#  devtools::load_all(".", quiet = TRUE)
#  cat("Local package loaded with devtools::load_all()\n")
#  hello()
# }

# Always run renv::snapshot with dev = TRUE
# suppressMessages({
#  tryCatch(
#    {
#      renv::snapshot(dev = TRUE, prompt = FALSE)
#      cat("renv snapshot updated with dev packages\n")
#    },
#    error = function(e) {
#      cat("Warning: Could not update renv snapshot -", e$message, "\n")
#    }
#  )
# })
