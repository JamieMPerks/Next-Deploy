#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <project-dir>"
  exit 1
fi
PROJECT_DIR="$1"
echo "==> Starting docker stack in $PROJECT_DIR"
pushd "$PROJECT_DIR"
echo "-> Building and starting containers..."
docker compose up -d --build
echo "-> Containers started. Showing logs (press Ctrl+C to exit tail)..."
docker compose ps
sleep 1
echo "==> Tailing logs:"
docker compose logs -f
popd
