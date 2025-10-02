#!/usr/bin/env bash
set -e

if [ $# -lt 2 ]; then
	echo "Usage: $0 <domain> <service> [--fast]"
	echo "Services: strapi | next | nginx | all"
	echo "Optional: --fast = restart without rebuild"
	exit 1
fi

DOMAIN="$1"
SERVICE="$2"
FAST="$3"
PROJECT_DIR="/var/www/$DOMAIN"

if [ ! -d "$PROJECT_DIR" ]; then
	echo "❌ Project directory $PROJECT_DIR does not exist."
	exit 1
fi

pushd "$PROJECT_DIR" >/dev/null

# Detect mode: check if nginx service exists in docker-compose
if docker compose config --services | grep -q "^nginx$"; then
	MODE="client"
else
	MODE="main"
fi

echo "==> Detected mode: $MODE"

restart_service() {
	local svc=$1
	if [ "$FAST" == "--fast" ]; then
		echo "-> Fast restart: $svc"
		docker compose restart "$svc"
	else
		echo "-> Rebuild + restart: $svc"
		docker compose stop "$svc" || true
		docker compose build "$svc"
		docker compose up -d "$svc"
	fi
}

case "$SERVICE" in
strapi)
	restart_service strapi
	;;
next)
	restart_service nextjs
	;;
nginx)
	if [ "$MODE" == "client" ]; then
		restart_service nginx
	else
		echo "-> Reloading system Nginx (main mode)"
		sudo nginx -t && sudo systemctl reload nginx
	fi
	;;
all)
	if [ "$FAST" == "--fast" ]; then
		echo "-> Fast restart: all services"
		docker compose restart
		if [ "$MODE" == "main" ]; then
			sudo nginx -t && sudo systemctl reload nginx
		fi
	else
		echo "-> Rebuild + restart: all services"
		docker compose down
		docker compose build
		docker compose up -d
		if [ "$MODE" == "main" ]; then
			sudo nginx -t && sudo systemctl reload nginx
		fi
	fi
	;;
*)
	echo "❌ Invalid service: $SERVICE (use strapi | next | nginx | all)"
	exit 1
	;;
esac

echo "-> Current container status:"
docker compose ps || true

popd >/dev/null
