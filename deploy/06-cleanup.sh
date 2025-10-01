#!/usr/bin/env bash
set -e
if [ $# -lt 2 ]; then
	echo "Usage: $0 <domain> <--client|--main> [--wipe]"
	echo "  <domain> = your project domain (e.g. client.com)"
	echo "  --client = project was generated in full Docker (self-contained)"
	echo "  --main   = project was generated for main VPS (host nginx as proxy)"
	echo "  --wipe   = optional, also deletes /var/www/<domain> project folder"
	exit 1
fi

DOMAIN="$1"
MODE="$2"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Cleaning up project: $DOMAIN ($MODE mode)"

# Stop and clean Docker
if [ -d "$PROJECT_DIR" ]; then
	cd "$PROJECT_DIR" || true
	docker compose down -v || true
else
	echo "⚠️  Project folder $PROJECT_DIR not found, skipping docker compose down"
fi

docker image prune -af || true
docker volume prune -f || true
docker builder prune -af || true

# If main mode, clean system nginx config
if [ "$MODE" == "--main" ]; then
	echo "-> Removing host Nginx configs for $DOMAIN"
	sudo rm -f "/etc/nginx/sites-available/$DOMAIN"
	sudo rm -f "/etc/nginx/sites-enabled/$DOMAIN"

	echo "-> Testing & reloading Nginx..."
	sudo nginx -t && sudo systemctl reload nginx || echo "⚠️ Nginx reload failed, please check config manually."
fi

# Remove project folder if wipe option passed
if [ "$3" == "--wipe" ]; then
	echo "⚠️  Wiping project directory $PROJECT_DIR"
	sudo rm -rf "$PROJECT_DIR"
fi

echo "✅ Cleanup complete for $DOMAIN ($MODE mode)"
echo "You can scaffold a new project with:"
echo "   bash deploy/01-generate-project.sh $DOMAIN $MODE"
