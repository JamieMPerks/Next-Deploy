#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
	echo "Usage: $0 <domain>"
	exit 1
fi

DOMAIN="$1"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Starting docker stack in $PROJECT_DIR"
pushd "$PROJECT_DIR"

echo "-> Building and starting containers..."
docker compose up -d --build

echo "-> Containers started. Current status:"
docker compose ps

echo "==> Tailing logs (Ctrl+C to exit)..."
docker compose logs -f

popd
