# ---- Builder ----
FROM node:18-alpine AS builder

# Install build tools (needed for some deps like sharp)
RUN apk add --no-cache build-base python3

WORKDIR /srv/app

# Copy only package manifests first (for caching npm install)
COPY package.json package-lock.json* yarn.lock* ./

# Install dependencies (dev included for building)
RUN npm install --frozen-lockfile || yarn install --frozen-lockfile

# Copy entire Strapi project
COPY . .

# Build Strapi admin panel
RUN npm run build


# ---- Runner ----
FROM node:18-alpine AS runner

WORKDIR /srv/app

# Copy package manifests to runner image
COPY package.json package-lock.json* yarn.lock* ./

# Install only production dependencies
RUN npm install --production --frozen-lockfile || yarn install --production --frozen-lockfile

# Copy built app & configs from builder stage
COPY --from=builder /srv/app ./

# Expose CMS port
EXPOSE 1337

# Run in production mode
ENV NODE_ENV=production
CMD ["npm", "run", "start"]
