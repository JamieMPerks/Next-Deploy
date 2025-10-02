#!/usr/bin/env bash
set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$(dirname "$0")/../templates"

echo "========================================"
echo "     🚀 Next-Deploy Master Utility"
echo "========================================"

# Ask domain
read -rp "Enter domain (e.g. clientsite.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
	echo "❌ Domain required"
	exit 1
fi

# Ask mode
echo
echo "Select mode:"
select MODE in "client" "main"; do
	case $MODE in
	client)
		MODE="--client"
		break
		;;
	main)
		MODE="--main"
		break
		;;
	esac
done

# Actions
echo
echo "Select action:"
options_action=(
	"install - Install dependencies (Docker, certbot, etc.)"
	"setup   - Full setup (01 project, 02 copy templates, 03 start)"
	"start   - Start/rebuild stack only (03)"
	"reload  - Restart service(s) (05)"
	"refresh - Reset CMS/frontend from templates (safe or hard)"
	"sync    - Sync project files back into templates + git commit/push"
	"cleanup - Remove project (04)"
	"exit    - Quit"
)
select opt in "${options_action[@]}"; do
	case $opt in
	install*)
		bash "$BASE_DIR/00-install-deps.sh"
		break
		;;
	setup*)
		bash "$BASE_DIR/01-generate-project.sh" "$DOMAIN" "$MODE"
		bash "$BASE_DIR/02-copy-templates.sh" "$DOMAIN"
		bash "$BASE_DIR/03-start-stack.sh" "$DOMAIN" "$MODE"
		break
		;;
	start*)
		bash "$BASE_DIR/03-start-stack.sh" "$DOMAIN" "$MODE"
		break
		;;
	reload*)
		echo "Reload which service?"
		select SVC in "strapi" "next" "nginx" "all"; do
			read -rp "Fast reload (no rebuild)? [y/N]: " FAST
			if [[ "$FAST" =~ ^[Yy]$ ]]; then
				bash "$BASE_DIR/05-reload-stack.sh" "$DOMAIN" "$SVC" --fast
			else
				bash "$BASE_DIR/05-reload-stack.sh" "$DOMAIN" "$SVC"
			fi
			break
		done
		break
		;;
	refresh*)
		PROJECT_DIR="/var/www/$DOMAIN"
		echo "Refresh type:"
		select REF in "safe - Reset code only (keep DB)" "hard - Reset EVERYTHING (code + DB volumes)"; do
			case $REF in
			safe*)
				(cd "$PROJECT_DIR" && docker compose down) || true
				rm -rf "$PROJECT_DIR/cms" "$PROJECT_DIR/frontend"
				bash "$BASE_DIR/02-copy-templates.sh" "$DOMAIN"
				bash "$BASE_DIR/03-start-stack.sh" "$DOMAIN" "$MODE"
				echo "✅ Safe refresh complete"
				break
				;;
			hard*)
				echo "⚠️ Hard reset will nuke DB volumes!"
				read -rp "Are you sure? (y/N): " CONFIRM
				[[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
				(cd "$PROJECT_DIR" && docker compose down -v) || true
				rm -rf "$PROJECT_DIR/cms" "$PROJECT_DIR/frontend"
				bash "$BASE_DIR/02-copy-templates.sh" "$DOMAIN"
				bash "$BASE_DIR/03-start-stack.sh" "$DOMAIN" "$MODE"
				echo "✅ Hard refresh complete"
				break
				;;
			esac
		done
		break
		;;
	sync*)
		read -rp "Enter commit message (default: Sync templates from $DOMAIN): " CMSG
		bash "$BASE_DIR/06-sync-templates.sh" "$DOMAIN" "$CMSG"
		break
		;;
	cleanup*)
		FLAGS=()
		read -rp "Wipe project folder (/var/www/$DOMAIN)? [y/N]: " WIPE
		[[ "$WIPE" =~ ^[Yy]$ ]] && FLAGS+=("--wipe")
		read -rp "Remove certs too? [y/N]: " CERTS
		[[ "$CERTS" =~ ^[Yy]$ ]] && FLAGS+=("--certs")
		bash "$BASE_DIR/04-cleanup.sh" "$DOMAIN" "$MODE" "${FLAGS[@]}"
		break
		;;
	exit*)
		echo "👋 Bye!"
		exit 0
		;;
	esac
done
