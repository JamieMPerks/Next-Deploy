#!/usr/bin/env bash
set -e
if [ $# -lt 2 ]; then
	echo "Usage: $0 <domain> <--client|--main>"
	exit 1
fi

DOMAIN="$1"
MODE="$2"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Starting docker stack for $DOMAIN in $MODE mode"
pushd "$PROJECT_DIR"

echo "-> Building and starting containers..."
docker compose up -d --build

echo "-> Containers started. Status:"
docker compose ps

if [ "$MODE" == "--client" ]; then
	echo "✅ Stack running with Docker Nginx on 80/443"
	echo "First-time SSL: docker compose up certbot-init && docker compose restart nginx"
else
	echo "✅ Stack running (Strapi:1337, Next.js:3000)"
	echo "System Nginx already proxies this domain."
	echo "First-time SSL: sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
fi

popd
