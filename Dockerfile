# Base image: Ubuntu, R, build tools and system libraries
FROM rocker/geospatial:4.5.1

LABEL maintainer="Willeke A'Campo <willeke.acampo@miljodir.no>"
LABEL description="R package for Grouping lynx observations into family groups based on spatio-temporal criteria."
LABEL version="0.0.1"

# Install devtools for local package installation
RUN R -e "install.packages('devtools', repos = 'https://cloud.r-project.org')" \
    && rm -rf /tmp/downloaded_packages

# Copy and install the local package
WORKDIR /home/rstudio/app
COPY NAMESPACE DESCRIPTION ./
COPY man/ man/
COPY R/ R/
COPY data/ data/

RUN R -e "devtools::install('.', dependencies = TRUE)" \
    && rm -rf /tmp/downloaded_packages

WORKDIR /home/rstudio

# Switch to non-root user (rstudio user defined in base image)
USER rstudio

CMD ["R", "-e", "gaupefam::hello()"]
