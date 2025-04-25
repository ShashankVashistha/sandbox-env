#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "🛠️ Building and starting sandbox using podman-compose..."
podman compose up -d --build

# Wait a bit to ensure the container is fully started
sleep 2

# List containers for the current compose project
CONTAINER_NAME=$(podman ps --filter "name=sandbox-sandbox" --format "{{.Names}}" | head -n 1)

if [ -z "$CONTAINER_NAME" ]; then
  echo "❌ Could not find a running container!"
  podman ps -a  # Help debug
  exit 1
fi

echo "✅ Container started: $CONTAINER_NAME"

# Cleanup function to stop and remove everything
cleanup() {
  echo ""
  echo "🧹 Cleaning up container, image, and volumes..."

  # Shut down containers and remove volumes
  podman compose down --volumes

  # Optionally remove the image
  IMAGE_NAME="sandbox-sandbox"
  if podman images --format "{{.Repository}}" | grep -q "^$IMAGE_NAME$"; then
    podman rmi "$IMAGE_NAME" || true
    echo "🗑️ Removed image: $IMAGE_NAME"
  fi
}

# Trap EXIT so that cleanup runs when user exits the shell
trap cleanup EXIT

# 🐚 Attach to the container shell
echo "🐚 Entering shell inside container..."
podman exec -it "$CONTAINER_NAME" bash
