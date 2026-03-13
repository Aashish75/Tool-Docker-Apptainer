#!/usr/bin/env bash
# Build the CyVerse-compatible LANDIS-II v8 image (Jupyter + LANDIS-II, minimal).
# Run from: Clean_Docker_LANDIS-II_8_AllExtensions (parent of CyVerse/).
#
# Both images are built for the same platform (default linux/amd64) so the base
# and CyVerse image match. Use linux/amd64 for CyVerse and for Mac M1/M2.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_NAME="${1:-landis-ii-v8-cyverse}"
PLATFORM="${2:-linux/amd64}"

cd "$REPO_ROOT"

echo "Step 1/2: Building base LANDIS-II v8 image (landis-ii_v8_linux) for $PLATFORM..."
docker build --platform "$PLATFORM" -t landis-ii_v8_linux --load .

echo "Step 2/2: Building CyVerse image ($IMAGE_NAME) for $PLATFORM..."
docker build --platform "$PLATFORM" -f CyVerse/Dockerfile -t "$IMAGE_NAME" --load .

echo "Done. Image: $IMAGE_NAME"
echo "Push to Harbor, then create the app in CyVerse using this image."
