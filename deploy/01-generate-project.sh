#!/usr/bin/env bash
set -e
if [ $# -lt 2 ]; then
	echo "Usage: $0 <domain> <--client|--main>"
	exit 1
fi

DOMAIN="$1"
MODE="$2"

if [ "$MODE" != "--client" ] && [ "$MODE" != "--main" ]; then
	echo "❌ Invalid mode. Use --client or --main"
	exit 1
fi

PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Creating project structure at $PROJECT_DIR"
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R "$(id -u):$(id -g)" "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"/{cms,frontend,nginx,certbot}

##########################################
# docker-compose.yml
##########################################

if [ "$MODE" == "--client" ]; then
	echo "-> Writing docker-compose.yml for CLIENT VPS (Docker Nginx binds 80/443)"
	cat >"$PROJECT_DIR/docker-compose.yml" <<'YAML'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: changeme
      POSTGRES_DB: app
    volumes:
      - db_data:/var/lib/postgresql/data
    networks: [web]

  strapi:
    build: ./cms
    networks: [web]

  nextjs:
    build: ./frontend
    networks: [web]

  nginx:
    image: nginx:stable
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    ports:
      - "80:80"
      - "443:443"
    depends_on: [nextjs, strapi]
    networks: [web]

  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: /bin/sh -c "trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done"

volumes:
  db_data: {}
networks:
  web:
YAML

	echo "-> Writing docker-compose.override.yml with certbot-init"
	cat >"$PROJECT_DIR/docker-compose.override.yml" <<YAML
version: "3.8"
services:
  certbot-init:
    image: certbot/certbot
    depends_on:
      - nginx
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    command: >
      sh -c "certbot certonly --webroot --webroot-path=/var/www/certbot
      -d $DOMAIN -d www.$DOMAIN
      --agree-tos --email admin@$DOMAIN
      --non-interactive --keep-until-expiring"
YAML

	echo "-> Writing nginx/default.conf inside project"
	cat >"$PROJECT_DIR/nginx/default.conf" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://nextjs:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://strapi:1337/;
        proxy_set_header Host \$host;
    }

    location /uploads/ {
        proxy_pass http://strapi:1337/uploads/;
    }

    location /admin/ {
        proxy_pass http://127.0.0.1:1337/admin/;
        proxy_set_header Host $host;
    }
}
EOF

else
	echo "-> Writing docker-compose.yml for MAIN VPS (expose 1337/3000, no Docker Nginx)"
	cat >"$PROJECT_DIR/docker-compose.yml" <<'YAML'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: changeme
      POSTGRES_DB: app
    volumes:
      - db_data:/var/lib/postgresql/data
    networks: [web]

  strapi:
    build: ./cms
    ports:
      - "1337:1337"
    networks: [web]

  nextjs:
    build: ./frontend
    ports:
      - "3000:3000"
    networks: [web]

volumes:
  db_data: {}
networks:
  web:
YAML

	##########################################
	# System Nginx Config for Host
	##########################################
	NGINX_FILE="/etc/nginx/sites-available/$DOMAIN"
	echo "-> Writing host Nginx config to $NGINX_FILE"
	sudo tee "$NGINX_FILE" >/dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:1337/;
        proxy_set_header Host \$host;
    }

    location /admin/ {
        proxy_pass http://strapi:1337/admin/;
        proxy_set_header Host $host;
    }

    location /uploads/ {
        proxy_pass http://127.0.0.1:1337/uploads/;
    }
}
EOF

	echo "-> Symlinking and reloading Nginx"
	sudo ln -sf "$NGINX_FILE" "/etc/nginx/sites-enabled/$DOMAIN"
	sudo nginx -t && sudo systemctl reload nginx
fi

##########################################
# Done
##########################################
echo "✅ Project scaffolded at $PROJECT_DIR"
if [ "$MODE" == "--client" ]; then
	echo "Docker stack includes Nginx + Certbot."
	echo "Next: Run scripts 02 -> 05. After 05, use: docker compose up certbot-init"
else
	echo "System Nginx configured for $DOMAIN -> Next.js:3000, Strapi:1337"
	echo "Next: Run scripts 02 -> 05. Then issue SSL with: sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
fi
