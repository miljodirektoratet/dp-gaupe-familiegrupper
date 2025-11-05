# Code Quality and Security Standards

This document outlines the code quality tools, security measures, and enforcement mechanisms used in this R package project.

## Code Quality Tools

- **[styler](https://styler.r-lib.org/):** Code formatter using `tidyverse_style()` function
- **[lintr](https://lintr.r-lib.org/):** Static code analysis with custom configuration (120 char line length, object usage linter disabled)
- **[testthat](https://testthat.r-lib.org/):** Testing framework for R packages
- **[roxygen2](https://roxygen2.r-lib.org/):** Documentation generator for R functions
- **[devtools](https://devtools.r-lib.org/):** Package development tools including R CMD check
- **[renv](https://rstudio.github.io/renv/):** Dependency management and reproducible environments

## Configuration Files

- **`.lintr`:** Custom lintr configuration with 120-character line length and disabled object usage linter
- **`.pre-commit-config.yaml`:** Pre-commit hooks using tidyverse style via styler package

## Security Tools

- **[Dependabot](https://github.com/dependabot):** Automated dependency updates and vulnerability scanning for R packages
- **[CodeQL](https://codeql.github.com/):** Semantic code analysis for security vulnerabilities
- **[R CMD check](https://r-pkgs.org/check.html):** Comprehensive package validation including security best practices

## Quality Gates

Code quality is enforced at multiple stages:

- **Local Development:** VS Code [settings](../.vscode/settings.json) and [extensions](../.vscode/extensions.json) provide real-time feedback
- **Pre-commit Hooks:** Automated checks before each commit
- **GitHub Actions:** Continuous integration checks on push and pull requests
- **Dependabot:** Automated security updates for dependencies
- **CodeQL:** Security vulnerability scanning

## Style and Convention Rules

Summary of style rules and enforcement in this repository (based on tidyverse style guide with customizations):

| Practice | Tidyverse Guide | Repository | Tool | Local check | pre-commit | GHA |
|----------|-----------------|------------|------|-------------|------------|-----|
| Max line length | 80  | 120  | lintr | `lintr::lint_package()` | ✅ | ✅ |
| Indentation | 2 spaces | tidyverse | styler | `styler::style_pkg()` | ✅ | ✅ |
| Naming convention - objects, functions | snake_case | tidyverse | lintr | `lintr::lint_package()` | ✅ | ✅ |
| Naming convention - files | snake_case | tidyverse | lintr | `lintr::lint_package()` | ✅ | ✅ |
| Assignment operator | `<-` | tidyverse | lintr | `lintr::lint_package()` | ✅ | ✅ |
| Spacing | consistent | tidyverse | styler | `styler::style_pkg()` | ✅ | ✅ |
| Documentation | roxygen2 | enforced | devtools | `devtools::document()` | ✅ | ✅ |
| Object usage linting | enabled | disabled | lintr | `lintr::lint_package()` | ❌ | ❌ |
| Language | English | tidyverse | not enforced | - | - | - |

## Testing and Security Rules

| Category | Practice | Tool | Local check | GHA File | pre-commit | GHA |
|----------|----------|------|-------------|----------|------------|-----|
| **Testing** | Unit tests | testthat | `devtools::test()` | `R-CMD-check.yaml` | ❌ | ✅ |
| **Testing** | Test coverage | covr | `covr::package_coverage()` | `R-CMD-check.yaml` | ❌ | ✅ |
| **Package Check** | R CMD check | devtools | `devtools::check()` | `R-CMD-check.yaml` | ❌ | ✅ |
| **Dependencies** | Package dependencies | renv | `renv::status()` | - | ❌ | ✅ |
| **Security** | Dependency vulnerabilities | Dependabot | - | `dependabot.yaml` | ❌ | ✅ |
| **Security** | Code vulnerabilities | CodeQL | - | `codeql-analysis.yaml` | ❌ | ✅ |
| **Security** | GitHub Actions security | Zizmor | `zizmor .github/workflows/` | `zizmor.yaml` | ✅ | ✅ |

## Local Development Workflow

To ensure your R package meets all quality standards before pushing to GitHub, run the local CI check:

```bash
task ci-local
```

This command runs the following checks:

- Code formatting and styling (styler)
- Code linting (lintr)
- R CMD check (devtools)
- Unit tests with coverage (testthat, covr)
- Package documentation (roxygen2)
- Dependency management (renv)

For GitHub repository and development environment configuration, see the [Setup Guide](setup-guide.md).
