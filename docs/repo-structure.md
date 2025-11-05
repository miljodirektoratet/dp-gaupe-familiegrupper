# Repository Structure

## Repository vs Package Naming

This project uses different names for different purposes:

- **Repository name**: `dp-gaupe-familiegrupper`
  - Used for: GitHub repository, Docker containers, data pipeline references
  - When to use: `git clone`, `remotes::install_github()`, Docker operations
  
- **Package name**: `gaupefam`
  - Used for: R package functions, `library()` calls, function references
  - When to use: `library(gaupefam)`, `gaupefam::hello()`, R code
