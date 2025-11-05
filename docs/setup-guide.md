# Setup Guide

<!--TODO:
[ ] review the whole guide
[ ] add a section for how to use this as a template for new projects.
-->

This guide will walk you through setting up the **dp-gaupe-familiegrupper** R package project on your local machine. Ensure you meet the prerequisites and choose the method that best fits your workflow.

> **Repository vs Package Names**: This repository is called `dp-gaupe-familiegrupper`, but the R package name is `gaupefam`. Use the repository name for installation (`remotes::install_github("miljodirektoratet/dp-gaupe-familiegrupper")`) and the package name for loading and using functions (`library(gaupefam)`).

- [Prerequisites](#prerequisites)
  - [Tools](#tools)
  - [Clone the Repository](#clone-the-repository)
- [Method 1: Taskfile setup](#method-1-taskfile-setup)
- [Method 2: Manual setup with renv](#method-2-manual-setup-with-renv)
- [Method 3: Devcontainer setup with VS Code](#method-3-devcontainer-setup-with-vs-code)
- [Method 4: Devcontainer setup with RStudio](#method-4-devcontainer-setup-with-rstudio)
- [VS Code Integration](#vs-code-integration)
  - [Manual R Environment Selection](#manual-r-environment-selection)
  - [Terminal Environment](#terminal-environment)
  - [R Notebook Setup](#r-notebook-setup)
  - [RStudio Integration](#rstudio-integration)
- [Development Container Technical Details](#development-container-technical-details)
  - [Container Architecture](#container-architecture)
  - [Customizing Containers](#customizing-containers)
  - [Container Profiles](#container-profiles)

## Prerequisites

### Tools

- [R](https://www.r-project.org/) (optional for local development without containers)
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/) or [VS Code](https://code.visualstudio.com/) (optional for local development without containers)
- [Git](https://git-scm.com/), [GitHub](https://github.com/) account, and [GitHub CLI](https://cli.github.com/)
- [Task](https://taskfile.dev/installation/) (necessary for method 1 - Taskfile setup)
- [Docker](https://docs.docker.com/engine/install/) (necessary for methods 3 and 4 - Devcontainer setup)
- [VS Code](https://code.visualstudio.com/) (necessary for method 3 - VS Code Devcontainer setup)

### Clone the Repository

```bash
# Clone from GitHub
gh repo clone miljodirektoratet/dp-gaupe-familiegrupper
cd dp-gaupe-familiegrupper

# Alternative: using git directly
git clone https://github.com/miljodirektoratet/dp-gaupe-familiegrupper.git
cd dp-gaupe-familiegrupper
```

## Method 1: Taskfile setup

If you have [Task](https://taskfile.dev/installation/) installed:

1. Set up the R environment using Task commands.

    ```bash
    # Development setup
    task dev-setup

    # See all available commands
    task --list
    ```

    The `dev-setup` task will:
    - Initialize renv environment with R dependencies
    - Set up pre-commit hooks
    - Run initial code quality checks (R CMD check, lintr)
    - Install the package in development mode

2. Test the installation:

    ```bash
    # Test the package
    task run
    # → "🚀 Hello from gaupefam !"
    # → Shows plot of Trøndelag

    # Run quality checks
    task check
    ```

3. Follow the Demo instructions to explore development commands and the R notebooks.

4. (Optional) Configure VS Code: [see VS Code Integration](#vs-code-integration).

## Method 2: Manual setup with renv

If you prefer a local setup without using Devcontainers or Task, follow these steps:

1. Set up the renv environment from the `DESCRIPTION` and `renv.lock` files.

    ```bash
    # Navigate to your cloned repository
    cd dp-gaupe-familiegrupper

    # Start R in the project directory
    R
    ```

    In R console:

    ```r
    # Initialize renv (if not already done)
    renv::init()

    # Restore packages from lockfile
    renv::restore()

    # Install development dependencies
    renv::install(c("devtools", "roxygen2", "testthat", "lintr", "styler"))

    # Load and test the package
    devtools::load_all()
    gaupefam::hello()
    ```

2. Test the installation:

    ```r
    # Test basic functionality
    gaupefam::hello()
    # → "🚀 Hello from gaupefam !"

    # Test plotting function
    map <- gaupefam::plot_trondelag()
    map

    # Run package checks
    devtools::check()

    # Run tests
    devtools::test()
    ```

3. Set up pre-commit hooks (optional but recommended):

    ```bash
    # Install pre-commit (if not already installed)
    pip install pre-commit
    # or: brew install pre-commit (macOS)

    # Install hooks
    pre-commit install
    ```

4. (Optional) Configure VS Code for development: [see VS Code Integration](#vs-code-integration).

## Method 3: Devcontainer setup with VS Code

If you have [Docker](https://docs.docker.com/engine/install/) and [VS Code](https://code.visualstudio.com/) installed:

1. Open the project folder in VS Code or [GitHub Codespaces](https://docs.github.com/en/codespaces).
2. When prompted, reopen the folder in the Devcontainer. If not prompted, you can manually trigger it via the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`) and select "Dev Containers: Reopen in Container".
3. The Devcontainer will automatically:
   - Configure the recommended VS Code settings and extensions
   - Install the recommended dev tools: Task, R, renv, pre-commit, etc.
   - Set up the renv environment with all dependencies
   - Initialize the R package development environment
4. Test the installation:
   - Test the package: `task run` or open R console and run `gaupefam::hello()`
   - Run quality checks: `task check` or `devtools::check()`
   - Run the example notebook: Open `notebooks/demo.ipynb` and select the R kernel
5. Follow the Demo instructions to explore development commands and R notebooks.

## Method 4: Devcontainer setup with RStudio

If you have [Docker](https://docs.docker.com/engine/install/) installed and prefer RStudio over VS Code:

1. **Start the RStudio Server devcontainer** using Docker Compose:

    ```bash
    # Check that Docker is running
    docker info

    # Build and start the RStudio Server dev container
    docker compose --profile dev-rstudio up --build -d

    # For faster startup (if image already exists and is up-to-date):
    # docker compose --profile dev-rstudio up -d

    # Open RStudio Server in your browser
    # RStudio will be available at http://localhost:8787pas
    ```

2. **Access RStudio Server**: Open your web browser and navigate to <http://localhost:8787>.

3. The RStudio devcontainer will automatically:
   - Set up a complete R development environment
   - Install all dependencies via renv
   - Configure the R package development environment
   - Provide a web-based RStudio interface

4. **Test the installation** in RStudio:

    ```r
    # Check working directory (should be /home/rstudio/project)
    getwd()
    
    # Check renv status
    renv::status(dev = TRUE)
    
    # Load and test the package
    devtools::load_all()
    gaupefam::hello()
    #> 🚀 Hello from gaupefam !
    
    # Test plotting function
    map <- gaupefam::plot_trondelag()
    map
    
    # Run package checks
    devtools::check()
    ```

5. **Development workflow** in RStudio:
   - Edit R files in the `R/` directory
   - Use `devtools::load_all()` to reload your package after changes
   - Run tests with `devtools::test()`
   - Generate documentation with `devtools::document()`

6. **Watch mode** (optional): For automatic reloading when files change:

    ```bash
    # Stop the current container
    docker compose --profile dev-rstudio down
    
    # Start in watch mode (auto-reloads on file changes)
    docker compose --profile dev-rstudio watch
    ```

    You can now edit files in RStudio (in the container) or your local IDE and see changes reflected automatically.

7. **Troubleshooting**:

    ```bash
    # Stop and remove the running container
    docker compose --profile dev-rstudio down
    
    # Remove the dev image (forces a full rebuild)
    docker rmi rdevcontainer-dev-rstudio
    
    # Rebuild with build logs for troubleshooting
    mkdir -p logs
    docker compose --profile dev-rstudio build | tee logs/rstudio-build.log
    ```

## VS Code Integration

The project includes VS Code configuration for optimal R development experience:

1. **Extensions**: Install recommended extensions from `.vscode/extensions.json` (VS Code will prompt you):
   - R Extension for Visual Studio Code
   - R Debugger
   - Docker extension
   - Git extensions

2. **Settings**: Code formatting, linting, and R language support are pre-configured in `.vscode/settings.json` and should be automatically detected.

3. **R Environment**: VS Code should automatically detect the renv environment created in the project.

### Manual R Environment Selection

The R extension should automatically detect the renv environment. If not, configure it manually:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "R: Select R Interpreter"
3. Choose the R interpreter in your system or the one used by renv

### Terminal Environment

To work with the R environment in your terminal:

```bash
# Start R in the project directory (renv will activate automatically)
cd dp-gaupe-familiegrupper
R

# Or use Radian for a better R console experience (if installed)
radian

# Check renv status
R -e "renv::status()"
```

### R Notebook Setup

To use the project package in R notebooks:

1. Open the demo notebook: `notebooks/demo.ipynb`
2. Select the R kernel when prompted
3. The R environment with all dependencies is already configured

**Note:** For Jupyter notebooks with R kernel, ensure you have IRkernel installed:

```r
# Install IRkernel if needed
install.packages("IRkernel")
IRkernel::installspec()
```

### RStudio Integration

If you prefer RStudio over VS Code:

1. Open RStudio
2. File → Open Project → Select `dp-gaupe-familiegrupper.Rproj`
3. renv will automatically activate
4. Install dependencies: `renv::restore()`
5. Load and test the package: `devtools::load_all()`

## Development Container Technical Details

### Container Architecture

The development containers include:

- **Base image**: `rocker/r-ver` with specified R version
- **System dependencies**: Common libraries for R package development
- **R packages**: Pre-installed development tools (devtools, roxygen2, testthat, etc.)
- **VS Code extensions**: R, Docker, Git, and more (for VS Code devcontainer)
- **Development tools**: Task, pre-commit, renv

### Customizing Containers

You can customize the container behavior by editing:

- **`.devcontainer/devcontainer.json`**: VS Code-specific settings, extensions, and container configuration
- **`.devcontainer/Dockerfile`**: Additional system dependencies or R packages
- **`docker-compose.yml`**: Service configuration for different profiles (dev-rstudio, etc.)
- **`renv.lock`**: R package versions and dependencies

### Container Profiles

The project supports multiple container profiles:

- **Default (VS Code)**: Development environment optimized for VS Code with Radian console
- **RStudio Server**: Web-based RStudio IDE accessible at <http://localhost:8787>
- **Production**: Minimal runtime container (see main README for usage)
