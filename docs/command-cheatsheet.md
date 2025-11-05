# Command Cheatsheet

> **Note**: This repository (`dp-gaupe-familiegrupper`) contains the R package `gaupefam`. Use the repository name for installation and git operations, use the package name (`gaupefam`) for R functions.

## R Development Commands

| Description | Command |
|-------------|---------|
| Clean environment | `rm(list = ls())` |
| Restart R session | `q() -> No` |
| Install packages | `install.packages("package_name")` |
| Install this package from GitHub | `remotes::install_github("miljodirektoratet/dp-gaupe-familiegrupper")` |
| Remove packages | `remove.packages("package_name")` |
| Load packages | `library(package_name)` |
| Load this package | `library(gaupefam)` |
| Check code quality | `lintr::lint_dir()`, `lintr::lint_package()` |
| Fix code style | `styler::style_dir("R/")`, `styler::style_pkg()` |
| Load your package | `devtools::load_all()` |
| Update documentation | `devtools::document()` |
| Run tests | `devtools::test()` |
| Check your package | `devtools::check()` |
| Build package | `devtools::build()` |
| Install local package | `devtools::install()` |
| Build README from Rmd | `devtools::build_readme()` |

## Package dependency Management (usethis)

| Description | Command |
|-------------|---------|
| Add package to Imports | `usethis::use_package("package_name")` |
| Add package to Suggests | `usethis::use_package("package_name", type = "Suggests")` |
| Add multiple packages to Suggests | `usethis::use_package(c("pkg1", "pkg2"), type = "Suggests")` |
| List packages in DESCRIPTION | `desc::desc_get_deps()` |
| Add MIT license | `usethis::use_mit_license()` |

## R Environment Management (renv)

| Description | Command |
|-------------|---------|
| Initialize renv | `renv::init()` |
| Initialize in explicit mode (recommended for packages) | `renv::init(settings = list(snapshot.type = "explicit"))` |
| Snapshot current state to renv.lock | `renv::snapshot()` |
| Snapshot development packages from DESCRIPTION | `renv::snapshot(dev = TRUE)` |
| Check status of renv | `renv::status()` |
| Check status with dev packages | `renv::status(dev = TRUE)` |
| List packages currently used in the project | `renv::dependencies()` |
| List package names recorded in renv.lock | `names(renv::lockfile_read()$Packages)` |
| Restore environment from renv.lock | `renv::restore()` |
| Checkout for a specific data | `renv::checkout("2023-10-01")` |
| Install a specific package with specific version | `renv::install("dplyr@1.0.10")` |
| Remove a package | `renv::remove("package_name")` |
| Clean unused packages | `renv::clean()` |
| Check cache location | `renv::paths$cache()` |
| Check library location | `renv::paths$library()` |

### renv clean slate reinstall scripts

Two bash scripts are available in [scripts](./scripts) for renv reset:

| Script | Description | Usage |
|--------|-------------|-------|
| `renv-reset-desc.sh` | Complete reset and reinstall from DESCRIPTION file | `./renv-reset-desc.sh` |
| `renv-reset-lock.sh` | Clean reinstall from existing renv.lock | `./renv-reset-lock.sh` |

## Pre-commit Commands

| Description | Command |
|-------------|---------|
| Install pre-commit hooks | `pre-commit install` |
| Run hooks on specific files | `pre-commit run --files <file1> <file2>` |
| Run hooks on R directory | `pre-commit run --files R/*` |
| Run hooks on all files | `pre-commit run --all-files` |
| Uninstall pre-commit hooks | `pre-commit uninstall` |
| Update hook versions | `pre-commit autoupdate` |
| Skip hooks for one commit | `git commit -m "message" --no-verify` |
| Clean pre-commit cache | `pre-commit clean` |

## R Test Commands

| Description | Command |
|-------------|---------|
| Create test infrastructure | `usethis::use_testthat()` |
| Create test file for function | `usethis::use_test("function_name")` |
| Run all tests | `devtools::test()` |
| Check test coverage | `covr::package_coverage()` |
| View coverage report | `covr::report()` |
| Zero coverage report. Show lines that are not tested. | `covr::zero_coverage(covr::package_coverage())` |

## R data Commands

| Description | Command |
|-------------|---------|
| Create data-raw infrastructure | `usethis::use_data_raw()` |
| Save dataset to data/ | `usethis::use_data(dataset_name, overwrite = TRUE)` |
| View metadata of a dataset* | `?dataset_name` or `help("dataset_name", package = "your_package")` |

*Ensure you are in an R base sessoin with the package loaded or in development mode with `devtools::load_all()`.

## Git Commands

| Description | Command |
|-------------|---------|
| Stage all changes | `git add .` |
| Commit with message | `git commit -m "commit message"` |
| Push to remote | `git push` |
| Pull from remote | `git pull` |
| Check status | `git status` |
| View commit history | `git log --oneline` |
| Create new branch | `git checkout -b branch-name` |
| Switch branches | `git checkout branch-name` |

## GitHub Actions

| Description | Command |
|-------------|---------|
| Create R-CMD-check workflow | `usethis::use_github_action("R-CMD-check")` |
| Create linting workflow | `usethis::use_github_action("lint")` |
| Trigger workflow | Push to GitHub repository or use the "Run workflow" button in the Actions tab |

## Docker Compose commands

| Description | Command |
|-------------|---------|
| Build docker image | `docker compose build` |
| Start docker container | `docker compose up -d` |
| Watch files    | `docker compose watch` |
| Stop docker container | `docker compose down` |
| View container logs | `docker compose logs -f` |
| Start with profile | `docker compose --profile <profile_name> up -d` |
| Stop with profile | `docker compose --profile <profile_name> down` |
| Watch with profile | `docker compose --profile <profile_name> watch` |
| List running containers | `docker compose ps` |
| List all containers | `docker ps -a` |
| List images | `docker images` |
| Remove image | `docker rmi image_id` |
| Remove unused images | `docker image prune` |
| Remove container | `docker rm container_id` |
| Remove all stopped containers | `docker container prune` |
| Remove all unused data (containers, networks, images, build cache) | `docker system prune -a` |
