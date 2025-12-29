# --- Install system dependencies: /init_script_r_gaupe.sh ---
# MUST BE ADDED TO CLUSTER OTHERWISE EACH NOTEBOOK NEEDS THIS CELL
# CELL RUNTIME: ca. 1 min
#!/bin/bash

# Databricks init script for R package dependencies
# This script installs system libraries required for R packages

set -e  # Exit on error

echo "Starting installation of R package dependencies..."

# Update package lists
apt-get update

# Install helper packages for R Package Development
echo "Installing R development libraries..."
apt-get install -y \
  libssl-dev \
  libfontconfig1-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libgit2-dev \
  libx11-dev

# Install spatial helpers
echo "Installing spatial libraries..."
apt-get install -y \
  cmake \
  gdal-bin \
  libgdal-dev \
  libudunits2-dev \
  libabsl-dev

# Install Java and Node.js development libraries
echo "Installing Java and Node.js development libraries..."
apt-get install -y \
  default-jdk \
  libnode-dev

# Install pandoc for RMarkdown
echo "Installing pandoc..."
apt-get install -y pandoc

# Set environment variables for renv
# Shared Cache and library paths across clusters
export RENV_PATHS_CACHE=/dbfs/cache/geospatial/R/renv/cache
export RENV_PATHS_LIBRARY=/dbfs/cache/geospatial/R/gaupe_familiegrupper/renv/library
echo "Installation completed successfully!"