# LANDIS-II v8 — CyVerse-compatible image

This directory contains the **CyVerse-compatible** Docker image for LANDIS-II v8: Jupyter + LANDIS-II (all extensions), minimal stack (no R, no macrosystems env). Suitable for CyVerse Discovery Environment, Harbor, and VICE/Jupyter apps.

## What’s in the image

- **Jupyter** (from `jupyter/r-notebook:hub-4.0.1`, same base as the macrosystems R Studio image) — notebooks and terminal. No R packages are installed; we only use this base for consistency with CyVerse setups.
- **LANDIS-II v8 and all extensions** — built by the **main** [Dockerfile](../Dockerfile) (Biomass Succession, NECN, PnET, ForCS, Base Fire, Scrapple, Dynamic Fuels/Fire, Harvest, Wind, BDA, Land Use, all Output extensions, etc.). The CyVerse Dockerfile does not re-run those steps; it copies the built `/bin/LANDIS_Linux` and `/bin/.dotnet` from the `landis-ii_v8_linux` image.
- **Same system packages as the main LANDIS Dockerfile**: gdal-bin, git, libgdal-dev, libjpeg62, libpng16-16, nano, pip, python3, vim, wget, libssl1.1 (for .NET), plus sudo/curl for CyVerse.
- **.NET 8** runtime and LANDIS console at `/bin/LANDIS_Linux` and `/bin/.dotnet`.
- **CyVerse entrypoint**: iRODS env stub, [cyverse-utils](https://github.com/CU-ESIIL/cyverse-utils), and `start-notebook.sh` so the app works with CyVerse’s gateway (token/password disabled).

## Repo setup

```bash
# Clone (if needed)
git clone https://github.com/LANDIS-II-Foundation/Tool-Docker-Apptainer.git
cd Tool-Docker-Apptainer/Clean_Docker_LANDIS-II_8_AllExtensions

# Or update existing
git fetch origin && git checkout main && git pull origin main
```

## Build (two steps)

The CyVerse image uses the standard LANDIS image as a build stage, so build in order. **Both images must be built for the same platform.** Use `--platform linux/amd64` so the image runs on CyVerse (amd64) and builds correctly on Mac M1/M2. The scripts and commands below use `linux/amd64` consistently.

```bash
cd /path/to/Tool-Docker-Apptainer/Clean_Docker_LANDIS-II_8_AllExtensions

# 1) Build base LANDIS-II v8 image (amd64)
docker build --platform linux/amd64 -t landis-ii_v8_linux --load .

# 2) Build CyVerse image (amd64)
docker build --platform linux/amd64 -f CyVerse/Dockerfile -t landis-ii-v8-cyverse --load .
```

Or use the script (defaults to `linux/amd64`):

```bash
./CyVerse/buildDockerImage.sh
# Custom image name
./CyVerse/buildDockerImage.sh my-registry.io/myorg/landis-ii-v8-cyverse
# Custom platform (optional second arg)
./CyVerse/buildDockerImage.sh landis-ii-v8-cyverse linux/arm64
```

## Run LANDIS-II

**Inside the container** (Jupyter terminal on CyVerse, or `docker run` shell locally), from a scenario directory:

```bash
# Single scenario (filename is often Scenario.txt or scenario.txt depending on the project)
dotnet $LANDIS_CONSOLE Scenario.txt

# Run all scenarios in the current directory
for d in */ ; do (cd "$d" && dotnet $LANDIS_CONSOLE Scenario.txt); done
```

**Local Docker run** (mount your scenario folder):

```bash
# Mac
docker run -it --mount type=bind,src="/path/to/your/LANDIS/",dst=/home/jovyan/scenarioFolder --name LANDIS1 landis-ii-v8-cyverse
# Then in the container: cd scenarioFolder && dotnet $LANDIS_CONSOLE Scenario.txt

# Windows PowerShell
docker run -it --mount type=bind,src="C:\Users\you\Desktop\NOCA",dst=/home/jovyan/scenarioFolder --name LANDIS1 landis-ii-v8-cyverse
```

**Add a custom extension DLL** (e.g. a custom climate library):

```bash
docker cp /path/to/Landis.Library.Climate-v5.dll CONTAINER_NAME:/bin/LANDIS_Linux/Core-Model-v8-LINUX/build/Release/
```

## Push to Harbor and use in CyVerse

1. Tag for your Harbor registry, e.g.  
   `docker tag landis-ii-v8-cyverse harbor.cyverse.org/your-org/landis-ii-v8-cyverse:latest`
2. Push:  
   `docker push harbor.cyverse.org/your-org/landis-ii-v8-cyverse:latest`
3. In CyVerse Discovery Environment, create an app (VICE/Jupyter) that uses this image. The image is set up so CyVerse’s proxy and env (e.g. `JUPYTERHUB_SERVICE_PREFIX`) work with the default `start-notebook.sh` launched from `entry.sh`.

## Files

- **Dockerfile** — Multi-stage: `FROM landis-ii_v8_linux` then Jupyter minimal + LANDIS + gocmd + entrypoint.
- **entry.sh** — CyVerse entry: iRODS env, cyverse-utils clone, `exec start-notebook.sh ...`.
- **buildDockerImage.sh** — Builds base image then CyVerse image (with `--platform linux/amd64` by default).

## Reference

- CyVerse/VICE-compatible pattern and `entry.sh` style from [CU-ESIIL/docker](https://github.com/CU-ESIIL/docker/tree/master/docker) (e.g. macrosystems R Studio image).
- LANDIS-II v8 Docker and extensions: [Tool-Docker-Apptainer](https://github.com/LANDIS-II-Foundation/Tool-Docker-Apptainer/tree/main/Clean_Docker_LANDIS-II_8_AllExtensions).
