#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
	echo "Usage: $0 <domain>"
	exit 1
fi

DOMAIN="$1"
PROJECT_DIR="/var/www/$DOMAIN"
TEMPLATE_DIR="$(dirname "$0")/../templates"

echo "==> Copying CMS + Frontend templates into $PROJECT_DIR"

# Ensure base dirs exist
mkdir -p "$PROJECT_DIR/cms"
mkdir -p "$PROJECT_DIR/frontend"

# Copy contents (preserve dirs, allow empty ones too)
rsync -av "$TEMPLATE_DIR/cms/" "$PROJECT_DIR/cms/" --exclude .gitkeep
rsync -av "$TEMPLATE_DIR/frontend/" "$PROJECT_DIR/frontend/" --exclude .gitkeep

# Ensure 'public' dirs always exist (Strapi + Next.js need them even if empty)
mkdir -p "$PROJECT_DIR/cms/public"
mkdir -p "$PROJECT_DIR/frontend/public"

echo "✅ Templates copied into $PROJECT_DIR (including cms/public and frontend/public)"
