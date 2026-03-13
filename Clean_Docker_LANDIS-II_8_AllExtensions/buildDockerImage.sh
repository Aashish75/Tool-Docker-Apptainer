#!/bin/bash

# Build the Docker image for linux/amd64 (CyVerse, cloud, and Mac M1/M2 emulation).
# Use the same platform when building the CyVerse image (see CyVerse/buildDockerImage.sh).
docker build --platform linux/amd64 -t landis-ii_v8_linux --load .