#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
	echo "Usage: $0 <domain> [commit message]"
	echo "Copies /var/www/<domain>/{cms,frontend} into ./templates/ and commits to Git"
	exit 1
fi

DOMAIN="$1"
COMMIT_MSG="${2:-Sync templates from $DOMAIN}"
PROJECT_DIR="/var/www/$DOMAIN"
REPO_ROOT="$(dirname "$0")/.."
TEMPLATE_DIR="$REPO_ROOT/templates"

echo "==> Preparing to sync templates from $PROJECT_DIR to $TEMPLATE_DIR"

# Ensure template dirs exist
mkdir -p "$TEMPLATE_DIR/cms"
mkdir -p "$TEMPLATE_DIR/frontend"

# Dry run first (preview)
echo
echo "-> Preview of changes (added/updated/deleted):"
rsync -avnc --delete "$PROJECT_DIR/cms/" "$TEMPLATE_DIR/cms/"
rsync -avnc --delete "$PROJECT_DIR/frontend/" "$TEMPLATE_DIR/frontend/"

echo
read -rp "⚠️ Apply these changes (this will overwrite templates and delete removed files)? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
	echo "❌ Sync aborted."
	exit 1
fi

# Actual sync
rsync -av --delete "$PROJECT_DIR/cms/" "$TEMPLATE_DIR/cms/"
rsync -av --delete "$PROJECT_DIR/frontend/" "$TEMPLATE_DIR/frontend/"

echo "✅ Templates updated locally at $TEMPLATE_DIR"

# Git stage + commit + push
cd "$REPO_ROOT"

git add templates/
if git diff --cached --quiet; then
	echo "⚠️ No changes to commit."
else
	echo "-> Committing: $COMMIT_MSG"
	git commit -m "$COMMIT_MSG"
	echo "-> Pushing to remote..."
	git push
	echo "✅ Sync committed & pushed."
fi
