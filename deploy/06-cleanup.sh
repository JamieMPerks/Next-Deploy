#!/usr/bin/env bash
set -e
if [ $# -lt 2 ]; then
	echo "Usage: $0 <domain> <--client|--main> [--wipe]"
	echo "  <domain> = your project domain (e.g. client.com)"
	echo "  --client or --main = mode used to generate the project"
	echo "  --wipe   = optional, also deletes /var/www/<domain> project folder"
	exit 1
fi

DOMAIN="$1"
MODE="$2"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Cleaning up Docker resources for $DOMAIN ($MODE mode)"

if [ -d "$PROJECT_DIR" ]; then
	cd "$PROJECT_DIR" || true
	docker compose down -v || true
else
	echo "⚠️  Project directory $PROJECT_DIR not found, skipping docker compose down"
fi

# Remove dangling images/volumes/build cache
docker image prune -af || true
docker volume prune -f || true
docker builder prune -af || true

if [ "$MODE" == "--main" ]; then
	echo "-> Removing system Nginx config for $DOMAIN"
	sudo rm -f "/etc/nginx/sites-available/$DOMAIN"
	sudo rm -f "/etc/nginx/sites-enabled/$DOMAIN"

	echo "-> Testing and reloading Nginx..."
	sudo nginx -t && sudo systemctl reload nginx || echo "⚠️ Failed to reload Nginx, check config manually"
fi

if [ "$3" == "--wipe" ]; then
	echo "⚠️  Wiping project folder $PROJECT_DIR"
	sudo rm -rf "$PROJECT_DIR"
fi

echo "✅ Cleanup complete for $DOMAIN in $MODE mode"
echo "You can now regenerate infra with:"
echo "   bash deploy/01-generate-project.sh $DOMAIN $MODE"
