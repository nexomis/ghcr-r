
FROM ubuntu:jammy

ARG R_VERSION
ENV R_VERSION=${R_VERSION}
ARG BIOC_VERSION
ENV BIOC_VERSION=${BIOC_VERSION}

# Install a specific version of using posit release of gdebi packages.
RUN export DEBIAN_FRONTEND=noninteractive \ 
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    gdebi-core curl ca-certificates apt-utils apt-file \
  && . /etc/os-release \
  && curl -O https://cdn.rstudio.com/r/${ID}-$(echo $VERSION_ID | sed 's/\.//g' )/pkgs/r-${R_VERSION}_1_amd64.deb \
  && gdebi --n r-${R_VERSION}_1_amd64.deb \
  && apt-get -y clean \
  && apt-get -y purge gdebi \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && rm r-${R_VERSION}_1_amd64.deb \
  && ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R \
  && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript \
  && R_HOME=$(Rscript -e 'R.home()' | sed -e 's/\[1\] //g' | sed -e 's/"//g') \
  && R_PROFILE=$R_HOME/etc/Rprofile.site \
  && echo "options(BioC_mirror = \"https://packagemanager.posit.co/bioconductor\")" >> $R_PROFILE \
  && echo "options(BIOCONDUCTOR_CONFIG_FILE = \"https://packagemanager.posit.co/bioconductor/config.yaml\")" >> $R_PROFILE \
  && echo "options(repos = c(CRAN = \"https://packagemanager.posit.co/cran/__linux__/${VERSION_CODENAME}/latest\"))" >> $R_PROFILE \
  && Rscript -e 'install.packages(c("BiocManager", "rspm"), repos = "https://cloud.r-project.org", clean = TRUE)' \
  && mkdir -p $R_HOME/site-library \
  && echo ".library <- \"${R_HOME}/site-library\"" >> $R_PROFILE
