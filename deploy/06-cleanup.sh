#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
	echo "Usage: $0 <domain> [--wipe]"
	echo "  <domain> = your project domain (e.g. client.com)"
	echo "  --wipe   = optional, also deletes /var/www/<domain> project folder"
	exit 1
fi

DOMAIN="$1"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Cleaning up Docker resources for $DOMAIN"

cd "$PROJECT_DIR"

# Stop and remove containers
docker compose down -v || true

# Remove dangling images
docker image prune -af || true

# Remove dangling volumes
docker volume prune -f || true

# Remove build cache
docker builder prune -af || true

if [ "$2" == "--wipe" ]; then
	echo "⚠️  Wiping project folder $PROJECT_DIR"
	rm -rf "$PROJECT_DIR"
fi

echo "✅ Cleanup complete for $DOMAIN"
echo "You can now regenerate infra with:"
echo "   bash deploy/01-generate-project.sh $DOMAIN"
