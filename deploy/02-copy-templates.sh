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

mkdir -p "$PROJECT_DIR/cms"
mkdir -p "$PROJECT_DIR/frontend"

cp -r "$TEMPLATE_DIR/cms/"* "$PROJECT_DIR/cms/" || true
cp -r "$TEMPLATE_DIR/frontend/"* "$PROJECT_DIR/frontend/" || true

echo "✅ Templates copied into $PROJECT_DIR"
