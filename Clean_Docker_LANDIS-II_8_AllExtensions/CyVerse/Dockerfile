# CyVerse-compatible image: LANDIS-II v8 + Jupyter (same stack as macrosystems, no R packages).
# All LANDIS extensions (Biomass Succession, NECN, PnET, Fire, Harvest, etc.) are built by
# the main Dockerfile and copied from landis-ii_v8_linux — we do not re-run those steps here.
#
# Build the base LANDIS image first, then this file:
#   docker build -t landis-ii_v8_linux .
#   docker build -f CyVerse/Dockerfile -t landis-ii-v8-cyverse .

ARG LOCAL_USER=jovyan
ARG LANDIS_FOLDER=/bin/LANDIS_Linux/Core-Model-v8-LINUX

# Use the standard LANDIS-II v8 image as the build stage (must be built first).
# That image already contains the full build: core + all extensions (Biomass Succession, etc.).
FROM landis-ii_v8_linux AS landis-build

# -----------------------------------------------------------------------------
# Final image: Jupyter (r-notebook base, same as macrosystems) + LANDIS-II + CyVerse
# -----------------------------------------------------------------------------
FROM jupyter/r-notebook:hub-4.0.1

USER root

# Same system packages as in Clean_Docker_LANDIS-II_8_AllExtensions/Dockerfile (for LANDIS runtime)
RUN apt-get update --yes && apt-get upgrade -y && \
    apt-get install -y \
      gdal-bin \
      git \
      libgdal-dev \
      libjpeg62 \
      libpng16-16 \
      nano \
      pip \
      python3 \
      python-is-python3 \
      vim \
      wget \
      sudo \
      curl && \
    wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    rm -f libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add jovyan to sudoers (no-password for common commands, like macrosystems image)
ARG PRIV_CMDS='/bin/ch*,/bin/cat,/bin/gunzip,/bin/tar,/bin/mkdir,/bin/ps,/bin/mv,/bin/cp,/usr/bin/apt*,/usr/bin/pip*,/opt/conda/bin/*'
RUN usermod -aG sudo ${LOCAL_USER} && \
    echo "${LOCAL_USER} ALL=NOPASSWD: ${PRIV_CMDS}" >> /etc/sudoers

# Copy .NET and LANDIS-II from the build stage
COPY --from=landis-build /bin/.dotnet /bin/.dotnet
COPY --from=landis-build /bin/LANDIS_Linux /bin/LANDIS_Linux

# LANDIS-II and .NET environment
ENV DOTNET_ROOT=/bin/.dotnet
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"
ENV LANDIS_EXTENSIONS_TOOL="${LANDIS_FOLDER}/build/Release/Landis.Extensions.dll"
ENV LANDIS_CONSOLE="${LANDIS_FOLDER}/build/Release/Landis.Console.dll"

# CyVerse gocmd (for iRODS/Data Store integration)
RUN GOCMD_VER=$(curl -L -s https://raw.githubusercontent.com/cyverse/gocommands/main/VERSION.txt) && \
    curl -L -s "https://github.com/cyverse/gocommands/releases/download/${GOCMD_VER}/gocmd-${GOCMD_VER}-linux-amd64.tar.gz" \
      | tar zxvf - -C /usr/local/bin

# Entrypoint for CyVerse (irods env, start-notebook.sh)
COPY CyVerse/entry.sh /bin/entry.sh
RUN chmod +x /bin/entry.sh

USER ${LOCAL_USER}
WORKDIR /home/${LOCAL_USER}

# Optional: ensure PATH is in .bashrc for terminal sessions
RUN echo "export PATH=\$PATH:/bin/.dotnet:/bin/.dotnet/tools" >> ~/.bashrc

# CyVerse expects no token/password; start-notebook.sh is called from entry.sh
ENTRYPOINT ["bash", "/bin/entry.sh"]
