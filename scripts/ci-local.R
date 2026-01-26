# author: Willeke A'Campo
# date: 2025-09-26
# description: R script to run development workflow before committing code.

# --- CLEAN START ---
rm(list = ls())
project_dir <- here::here()
print(project_dir)
setwd(project_dir)

# CHECK: renv status and snapshot to dev
renv::status(dev = TRUE)
renv::snapshot(dev = TRUE)

# CHECK: package and functions load
devtools::load_all()
gaupefam::hello()

# Check package functions have documentation
?gaupefam::create_distance_matrix
?gaupefam::create_time_matrix
?gaupefam::data
?gaupefam::hello
?gaupefam::order_observations
?gaupefam::plot_norway

# CHECK: code quality
lintr::lint_dir() # Check only
styler::style_dir(project_dir, exclude_dirs = c("renv", "dump", "packrat", ".git")) # Fix

# CHECK: package documentation and README
devtools::document() # creates docs in man/*.Rd
devtools::build_readme() # updates README.md based on README.Rmd

# CHECK: package tests and checks
devtools::test()
devtools::check()

# PRE-COMMIT: code quality full project
system("pre-commit run --all-files")

# DELETE: delete a function from the package
# - remove .R file from R/
# - remove tests from tests/testthat/

# update documentation after deleting functions
# - removes function from namespace
# - removes functions documentation from man/*.Rd
devtools::document()
