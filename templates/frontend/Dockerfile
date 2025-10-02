# ---- Builder ----
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies first (for better caching)
COPY package.json package-lock.json* yarn.lock* ./
RUN npm install --frozen-lockfile || yarn install --frozen-lockfile

# Copy the whole project
COPY . .

# Build the Next.js app
RUN npm run build


# ---- Runner ----
FROM node:18-alpine AS runner

# Set working dir
WORKDIR /app

# Copy needed files from builder stage
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json* ./ 
COPY --from=builder /app/yarn.lock* ./ 
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Expose frontend port
EXPOSE 3000

# Run Next.js in production mode
CMD ["npm", "run", "start"]
