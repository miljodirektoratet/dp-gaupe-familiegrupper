FROM rocker/geospatial:4.5.1

# --- SYSTEM LAYER ---
# PYTHON: Install uv package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_PYTHON_INSTALL_DIR=/opt/python
RUN uv python install 3.12

# python-tools venv with radian and pre-commit
RUN uv venv /opt/python-tools \
    && uv pip install --python /opt/python-tools radian pre-commit
ENV PATH="/opt/python-tools/bin:$PATH"
RUN echo 'alias r="radian"' >> /root/.bashrc \
    && echo 'alias r="radian"' >> /home/rstudio/.bashrc

# R: Install renv package manager
# httpgd >= 2.0.4 (r-multiverse), languageserver are snapped in renv.lock
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')" \
    && rm -rf /tmp/downloaded_packages

# Set renv cache and library paths to workspace (not global)
WORKDIR /home/rstudio/workspace

# Create cache directory with proper ownership for rstudio user
RUN mkdir -p /renv/cache \
    && chown -R rstudio:rstudio /renv/cache

# Copy renv configuration files (triggers rebuild when dependencies change)
COPY .devcontainer/docker.Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json
COPY renv.lock renv.lock

# --- CACHE AND LIBRARY LAYER ---
# Use build cache but ensure cache is available at runtime
# Mount cache to same path as runtime to avoid path issues
# Single stage with build cache mount
RUN --mount=type=cache,target=/docker-build-cache \
    RENV_PATHS_CACHE=/docker-build-cache \
    Rscript -e "renv::restore()" && \
    cp -r /docker-build-cache/* /renv/cache

# runtime cache path
ENV RENV_PATHS_CACHE=/renv/cache

# RUNTIME: Source code provided via bind mount
# No COPY needed - compose.yml handles this with:
# volumes: - .:/home/rstudio/workspace

RUN chown -R rstudio:rstudio /home/rstudio/workspace
