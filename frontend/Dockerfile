FROM node:18-alpine AS builder
WORKDIR /app

# Only copy package.json (no yarn.lock required)
COPY package.json ./
RUN yarn install

COPY . .
RUN yarn build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app ./
EXPOSE 3000
CMD ["yarn", "start"]
