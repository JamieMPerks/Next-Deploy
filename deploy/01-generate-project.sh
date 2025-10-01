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
sudo chown -R "$(id -u):$(id -g)" "$PROJECT_DIR"

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
# docker-compose.override.yml
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
    "develop": "strapi develop",
    "start": "strapi start",
    "build": "strapi build"
  },
  "dependencies": {
    "@strapi/strapi": "^4.25.0",
    "@strapi/plugin-i18n": "^4.25.0",
    "@strapi/plugin-users-permissions": "^4.25.0",
    "@strapi/plugin-upload": "^4.25.0",
    "pg": "^8.11.0"
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
# Scaffold minimal Next.js app
##########################################
mkdir -p "$PROJECT_DIR/frontend/pages/blog"
mkdir -p "$PROJECT_DIR/frontend/styles"

# Home page
cat >"$PROJECT_DIR/frontend/pages/index.js" <<'EOF'
export default function Home() {
  return (
    <main style={{ padding: "3rem", textAlign: "center" }}>
      <h1>Next.js + Strapi Boilerplate</h1>
      <p>Your site is up and running 🎉</p>
    </main>
  );
}
EOF

# Blog index page
cat >"$PROJECT_DIR/frontend/pages/blog/index.js" <<'EOF'
export default function BlogIndex() {
  return (
    <main style={{ padding: "3rem" }}>
      <h1>Blog</h1>
      <p>This will list blog posts pulled from Strapi.</p>
    </main>
  );
}
EOF

# Blog single page
cat >"$PROJECT_DIR/frontend/pages/blog/[slug].js" <<'EOF'
export default function BlogPost({ slug }) {
  return (
    <main style={{ padding: "3rem" }}>
      <h1>Blog Post: {slug}</h1>
      <p>This will display blog content from Strapi.</p>
    </main>
  );
}
EOF

# _app.js (for global styles)
cat >"$PROJECT_DIR/frontend/pages/_app.js" <<'EOF'
import '../styles/globals.css'

export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />
}
EOF

# _document.js (custom HTML boilerplate)
cat >"$PROJECT_DIR/frontend/pages/_document.js" <<'EOF'
import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        {/* Custom meta tags, fonts, etc go here */}
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
EOF

# globals.css (basic CSS starter, Tailwind-ready)
cat >"$PROJECT_DIR/frontend/styles/globals.css" <<'EOF'
/* Global styles or Tailwind imports */
body {
  margin: 0;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI',
    Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
}

h1, h2, h3 {
  margin-bottom: 1rem;
}
EOF

##########################################
# Done
##########################################
echo "✅ Project scaffolded at $PROJECT_DIR"
echo "Next step:"
echo "   Run: bash deploy/02-generate-cms-schema.sh $DOMAIN"
