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
	echo "-> Writing docker-compose.yml for CLIENT VPS (Docker Nginx + Certbot inside stack)"
	cat >"$PROJECT_DIR/docker-compose.yml" <<YAML
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
    depends_on:
    - postgres
    ports:
    - "1337:1337"
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: app
      DATABASE_USERNAME: app
      DATABASE_PASSWORD: changeme
      APP_KEYS: "supersecretkey1,supersecretkey2,supersecretkey3"
      HOST: 0.0.0.0
      PORT: 1337
    networks: [web]


  nextjs:
    build: ./frontend
    depends_on:
      - strapi
    environment:
      NEXT_PUBLIC_STRAPI_URL: http://strapi:1337
      REVALIDATE_SECRET: \${REVALIDATE_SECRET:-supersecret123}
    networks: [web]

  nginx:
    image: nginx:stable
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    depends_on:
      - nextjs
      - strapi
    networks: [web]

  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: >-
      /bin/sh -c "trap exit TERM;
                  while :; do certbot renew;
                  sleep 12h & wait \$${!}; done"

volumes:
  db_data: {}
networks:
  web:
YAML

	echo "-> Writing docker-compose.override.yml certbot-init"
	cat >"$PROJECT_DIR/docker-compose.override.yml" <<YAML
services:
  certbot-init:
    image: certbot/certbot
    depends_on:
      - nginx
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    command: >-
      sh -c "certbot certonly --webroot --webroot-path=/var/www/certbot
      -d $DOMAIN
      --agree-tos --email admin@$DOMAIN
      --non-interactive --keep-until-expiring"
YAML

	echo "-> Writing nginx/default.conf"
	cat >"$PROJECT_DIR/nginx/default.conf" <<EOF
server {
    listen 80;
    server_name $DOMAIN;

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
        proxy_pass http://strapi:1337/admin/;
        proxy_set_header Host \$host;
    }
}
EOF

else
	echo "-> Writing docker-compose.yml for MAIN VPS (system Nginx proxy + host certbot)"
	cat >"$PROJECT_DIR/docker-compose.yml" <<YAML
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
    depends_on:
    - postgres
    ports:
    - "1337:1337"
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: app
      DATABASE_USERNAME: app
      DATABASE_PASSWORD: changeme
      APP_KEYS: "supersecretkey1,supersecretkey2,supersecretkey3"
      HOST: 0.0.0.0
      PORT: 1337
    networks: [web]

  nextjs:
    build: ./frontend
    depends_on:
      - strapi
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_STRAPI_URL: http://127.0.0.1:1337
      REVALIDATE_SECRET: \${REVALIDATE_SECRET:-supersecret123}
    networks: [web]

volumes:
  db_data: {}
networks:
  web:
YAML

	##################################################
	# System Nginx Config
	##################################################
	NGINX_FILE="/etc/nginx/sites-available/$DOMAIN"
	echo "-> Writing host Nginx config to $NGINX_FILE"
	sudo tee "$NGINX_FILE" >/dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:1337/;
        proxy_set_header Host \$host;
    }

    location /uploads/ {
        proxy_pass http://127.0.0.1:1337/uploads/;
    }

    location /admin/ {
        proxy_pass http://127.0.0.1:1337/admin/;
        proxy_set_header Host \$host;
    }
}
EOF

	echo "-> Symlinking and reloading Nginx"
	sudo ln -sf "$NGINX_FILE" "/etc/nginx/sites-enabled/$DOMAIN"
	sudo nginx -t && sudo systemctl reload nginx

	##################################################
	# Request SSL on host
	##################################################
	if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
		echo "-> Requesting Let's Encrypt certificate"
		sudo certbot certonly --nginx -d "$DOMAIN" \
			--agree-tos -m "admin@$DOMAIN" --non-interactive
	fi

	echo "-> Adding HTTPS block"
	sudo tee -a "$NGINX_FILE" >/dev/null <<EOF

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:1337/;
        proxy_set_header Host \$host;
    }

    location /uploads/ {
        proxy_pass http://127.0.0.1:1337/uploads/;
    }

    location /admin/ {
        proxy_pass http://127.0.0.1:1337/admin/;
        proxy_set_header Host \$host;
    }

    error_page 404 /__custom_404.html;
}
EOF

	sudo nginx -t && sudo systemctl reload nginx
fi

echo "✅ Project scaffolded in $PROJECT_DIR"
if [ "$MODE" == "--client" ]; then
	echo "Next: Run scripts 02 -> 05. After 05, bootstrap cert with:"
	echo "   docker compose up certbot-init"
else
	echo "Next: Run scripts 02 -> 05. SSL should auto-issue on host."
fi
