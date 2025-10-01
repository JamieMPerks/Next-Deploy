FROM node:18-bullseye

WORKDIR /srv/app
COPY package.json yarn.lock ./
RUN corepack enable && corepack prepare yarn@stable --activate
RUN yarn install --frozen-lockfile

COPY . .

ENV DATABASE_CLIENT=${DATABASE_CLIENT:-postgres}
ENV DATABASE_HOST=${DATABASE_HOST:-postgres}
ENV DATABASE_PORT=${DATABASE_PORT:-5432}
ENV DATABASE_NAME=${DATABASE_NAME:-app}
ENV DATABASE_USERNAME=${DATABASE_USERNAME:-app}
ENV DATABASE_PASSWORD=${DATABASE_PASSWORD:-changeme}

EXPOSE 1337

CMD ["yarn", "develop"]
