FROM rocker/geospatial:4.4.0

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

# set up project workspace and renv (rstudio users must have read/write access)
RUN mkdir -p /home/rstudio/cache /home/rstudio/workspace \
 && chown -R rstudio:rstudio /home/rstudio/cache /home/rstudio/workspace \
 && chmod 2775 /home/rstudio/cache
ENV RENV_PATHS_CACHE=/home/rstudio/cache

USER rstudio
WORKDIR /home/rstudio/workspace

# Copy renv configuration files (triggers rebuild when dependencies change)
COPY --chown=rstudio:rstudio .devcontainer/docker.Rprofile .Rprofil
COPY --chown=rstudio:rstudio renv.lock renv.lock

# Restore R package environment using renv.lock
# Running renv::restore() inside the Dockerfile (uncommenting the line), installs and caches packages into the image layer, not the runtime volume.
# Running renv::restore() at container startup, installs packages into the container and caches them to the mounted volume (e.g., /home/rstudio/cache), which persists across rebuilds.
# RUN R -e "renv::restore()"
