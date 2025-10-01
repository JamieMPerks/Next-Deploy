FROM node:18-bullseye

WORKDIR /srv/app

# Copy only package.json (no yarn.lock to avoid errors if missing)
COPY package.json ./

# Enable corepack and install dependencies
RUN corepack enable && corepack prepare yarn@stable --activate
RUN yarn install

# Copy the rest of the project (schemas, bootstrap, etc.)
COPY . .

# Ensure schema & bootstrap folders exist
RUN mkdir -p ./src/api/page/content-types/page \
    ./src/api/post/content-types/post \
    ./src/components/sections \
    ./config/functions

# Copy schema & seeder directly into image
COPY ./strapi-seeds/page.schema.json ./src/api/page/content-types/page/schema.json
COPY ./strapi-seeds/post.schema.json ./src/api/post/content-types/post/schema.json
COPY ./strapi-seeds/hero.json ./src/components/sections/hero.json
COPY ./strapi-seeds/text-block.json ./src/components/sections/text-block.json
COPY ./strapi-seeds/services.json ./src/components/sections/services.json
COPY ./strapi-seeds/service-item.json ./src/components/sections/service-item.json
COPY ./strapi-seeds/bootstrap.js ./config/functions/bootstrap.js

EXPOSE 1337
CMD ["yarn", "develop"]
