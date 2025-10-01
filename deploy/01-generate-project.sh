#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi
DOMAIN="$1"
PROJECT_DIR="/var/www/$DOMAIN"

echo "==> Creating project structure at $PROJECT_DIR"
sudo mkdir -p "$PROJECT_DIR"
sudo chown "$(id -u):$(id -g)" "$PROJECT_DIR"

echo "-> Creating cms, frontend, nginx, certbot folders..."
mkdir -p "$PROJECT_DIR"/{cms,frontend,nginx,certbot}
mkdir -p "$PROJECT_DIR"/deploy

echo "-> Writing docker-compose.yml into $PROJECT_DIR"
cat > "$PROJECT_DIR/docker-compose.yml" <<'YAML'
version: "3.8"
services:
  postgres:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: changeme
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - web

  strapi:
    build: ./cms
    depends_on:
      - postgres
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: app
      DATABASE_USERNAME: app
      DATABASE_PASSWORD: changeme
      APP_KEYS: some_app_key
      JWT_SECRET: some_jwt_secret
      ADMIN_JWT_SECRET: some_admin_jwt
    volumes:
      - ./cms:/srv/app
    networks:
      - web

  nextjs:
    build: ./frontend
    environment:
      NEXT_PUBLIC_STRAPI_URL: http://strapi:1337
    volumes:
      - ./frontend:/usr/src/app
    networks:
      - web

  nginx:
    image: nginx:stable
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    depends_on:
      - nextjs
      - strapi
    networks:
      - web

  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: /bin/sh -c "trap exit TERM; while :; do sleep 12h & wait $${!}; certbot renew; done"
    networks:
      - web

volumes:
  db_data:

networks:
  web:
    driver: bridge
YAML

echo "-> Writing docker-compose.override.yml (certbot init)."
cat > "$PROJECT_DIR/docker-compose.override.yml" <<'YAML'
version: "3.8"
services:
  certbot-init:
    image: certbot/certbot
    depends_on:
      - nginx
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    command: sh -c "certbot certonly --webroot --webroot-path=/var/www/certbot -d {DOMAIN} --agree-tos --email admin@{DOMAIN} --non-interactive --keep-until-expiring"
YAML

echo "-> Copying template deploy scripts..."
cp -r "$(pwd)/deploy"/* "$PROJECT_DIR/deploy/" || true

echo "-> Done. Edit credentials and review docker-compose.yml to suit your needs."
echo "Project scaffolded at $PROJECT_DIR"
