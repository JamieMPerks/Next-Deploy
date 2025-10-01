FROM node:18-bullseye

WORKDIR /usr/src/app
COPY package.json yarn.lock ./
RUN corepack enable && corepack prepare yarn@stable --activate
RUN yarn install --frozen-lockfile

COPY . .

ENV PORT 3000
EXPOSE 3000
CMD ["yarn", "start"]
