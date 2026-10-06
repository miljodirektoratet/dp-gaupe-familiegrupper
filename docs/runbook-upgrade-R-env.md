# Runbook: Upgrade R Environment and Dependencies

## Purpose

This runbook defines the required steps to safely:

1. Upgrade to a newer R version.
2. Add or upgrade R package dependencies.
3. Validate behavior locally, in the dev container, in the Docker package image, and in Databricks pipelines that depend on this package.

## Scope

Applies to:

1. `dp-gaupe-familiegrupper`.
2. Downstream Databricks pipelines in `dp-databricks` that install and run `gaupefam`.

## Inputs

Before starting, confirm:

1. Target R version (if upgrading R).
2. Target dependency changes.
3. Pinned CRAN snapshot URL.
4. Whether `R-Universe` is still required.

## Repository Files to Check

1. `.Rprofile`
2. `DESCRIPTION`
3. `renv.lock`
4. `Dockerfile`
5. `.devcontainer/dev.Dockerfile`
6. `.devcontainer/docker.Rprofile`
7. `.devcontainer/docker-compose.yml`
8. `compose.yml`

## Standard Source Policy

Use deterministic repository settings:

```r
options(
  repos = c(
    "CRAN" = "https://packagemanager.posit.co/cran/__linux__/jammy/2026-09-01",
    "R-Universe" = "https://apache.r-universe.dev"
  ),
  download.file.method = "libcurl"
)
```

If `R-Universe` is no longer needed, remove it from all relevant config files in one PR and verify installs still pass.

## Change Types

1. R version upgrade.
2. Dependency-only change.
3. Combined R and dependency change.

## Procedure

### 1. Create an Isolated Branch

```bash
git checkout -b chore/upgrade-r-env-YYYYMMDD
```

### 2. Update Configuration

Apply relevant edits:

1. For R upgrade: update base images in `Dockerfile` and `.devcontainer/dev.Dockerfile`.
2. For dependency changes: update `DESCRIPTION` (`Imports`, `Suggests`, `Remotes`).
3. Keep source policy aligned in `.Rprofile`, `.devcontainer/docker.Rprofile`, and Docker build/install commands.

### 3. Rebuild or Refresh `renv.lock`

From repo root:

```bash
R -q
```

In R:

```r
source("renv/activate.R")

# Verify repos are correct before install/snapshot
getOption("repos")
getOption("download.file.method")

# Discover focused dependencies (avoid scanning archival folders)
deps <- unique(renv::dependencies(path = c("R", "tests", "DESCRIPTION", "README.Rmd", "scripts"))$Package)
deps <- deps[!is.na(deps) & deps != "R"]
deps <- setdiff(deps, c("gaupefam", "stats", "utils", "tools", "grid", "parallel"))

renv::install(deps)
renv::install(c("devtools", "roxygen2", "testthat", "lintr", "styler", "remotes"))

renv::snapshot(prompt = FALSE, dev = TRUE)
renv::status(dev = TRUE)
```

Expected: `No issues found -- the project is in a consistent state.`

### 4. Local Validation

From repo root:

```bash
R -q -e "source('renv/activate.R'); renv::status(dev = TRUE)"
R -q -e "source('renv/activate.R'); devtools::load_all(); gaupefam::hello(); devtools::test()"
R -q -e "source('renv/activate.R'); devtools::check()"
```

### 5. Fresh Cache Validation (Local)

```bash
export RENV_PATHS_CACHE=/tmp/renv_cache_local_test_$(date +%s)
R -q -e "source('renv/activate.R'); renv::restore(prompt = FALSE); renv::status(dev = TRUE)"
```

### 6. Dev Container Validation

```bash
cd .devcontainer
docker compose --profile vscode build --no-cache
docker compose --profile vscode up -d
docker compose --profile vscode exec vscode R -q -e "renv::status(dev=TRUE); devtools::load_all(); gaupefam::hello(); devtools::test()"
docker compose --profile vscode down
```

Optional RStudio profile:

```bash
cd .devcontainer
docker compose --profile rstudio up --build -d
```

Then run equivalent checks in RStudio at `http://localhost:8787`.

### 7. Production-Like Docker Package Check

From repo root:

```bash
docker compose build --no-cache test
docker compose run --rm test
```

Expected: container command exits successfully.

### 8. Databricks Checks in `dp-databricks`

1. Align repository source policy with this repo.
2. Regenerate lockfile via notebook `setup_gaupe_familiegrupper_renv_lockfile`.
3. Build fresh cache via notebook `setup_gaupe_familiegrupper_renv_cache`.
4. Run at least one dependent job end-to-end and verify:
   - package install succeeds
   - package loads successfully
   - pipeline output is produced as expected

## Acceptance Criteria

All must pass:

1. `renv::status(dev = TRUE)` clean locally.
2. `devtools::test()` and `devtools::check()` pass locally.
3. Fresh-cache restore test passes.
4. Dev container validation passes.
5. Docker package test service passes.
6. Databricks lockfile and cache notebooks pass in `dp-databricks`.
7. One downstream Databricks pipeline run succeeds with the updated package environment.

## Rollback

If checks fail and you need to back out:

```bash
git restore .Rprofile .devcontainer/dev.Dockerfile .devcontainer/docker.Rprofile Dockerfile docs/setup-guide.md renv.lock DESCRIPTION
```

Then re-run baseline local checks.

## PR Checklist

1. Config changes are scoped to environment/dependency upgrade only.
2. `renv.lock` updated and reviewed.
3. Evidence of local, dev container, and Docker package checks attached.
4. Databricks notebook runs documented.
5. Rollback notes included in PR description.
