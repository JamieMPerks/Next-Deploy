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

##########################################
# docker-compose.yml
##########################################
echo "-> Writing docker-compose.yml..."
cat >"$PROJECT_DIR/docker-compose.yml" <<'YAML'
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

##########################################
# docker-compose.override.yml (certbot init)
##########################################
echo "-> Writing docker-compose.override.yml..."
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

##########################################
# CMS (Strapi)
##########################################
echo "-> Writing Strapi Dockerfile and package.json..."
cat >"$PROJECT_DIR/cms/Dockerfile" <<'EOF'
FROM node:18-bullseye

WORKDIR /srv/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 1337
CMD ["npm", "run", "develop"]
EOF

cat >"$PROJECT_DIR/cms/package.json" <<'EOF'
{
  "name": "strapi-cms",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "develop": "strapi start",
    "start": "strapi start",
    "build": "strapi build"
  },
  "dependencies": {
    "strapi": "4.24.2"
  }
}
EOF

##########################################
# Frontend (Next.js)
##########################################
echo "-> Writing Next.js Dockerfile and package.json..."
cat >"$PROJECT_DIR/frontend/Dockerfile" <<'EOF'
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 3000
CMD ["npm", "run", "start"]
EOF

cat >"$PROJECT_DIR/frontend/package.json" <<'EOF'
{
  "name": "nextjs-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "13.4.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}
EOF

##########################################
# Done
##########################################
echo "-> Project scaffolded at $PROJECT_DIR"
echo "Next steps:"
echo "1. Run: bash deploy/02-seed-strapi.sh $PROJECT_DIR"
echo "2. Run: bash deploy/03-start-stack.sh $PROJECT_DIR"
echo "3. Init SSL once: cd $PROJECT_DIR && docker compose up certbot-init && docker compose restart nginx"
