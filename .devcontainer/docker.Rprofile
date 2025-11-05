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

# Print RENV_PROJECT, RENV_PATHS_LIBRARY, RENV_PATHS_CACHE
cat("renv library:", renv::paths$library(), "\n")
cat("renv global cache:", renv::paths$cache(), "\n")

# Load the package in development mode
if (requireNamespace("devtools", quietly = TRUE) && file.exists("DESCRIPTION")) {
  devtools::load_all(".", quiet = TRUE)
  cat("Local package loaded with devtools::load_all()\n")
  hello()
}

# Always run renv::snapshot with dev = TRUE
suppressMessages({
  tryCatch(
    {
      renv::snapshot(dev = TRUE, prompt = FALSE)
      cat("renv snapshot updated with dev packages\n")
    },
    error = function(e) {
      cat("Warning: Could not update renv snapshot -", e$message, "\n")
    }
  )
})
