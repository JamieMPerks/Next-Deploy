FROM node:18-bullseye

WORKDIR /srv/app

COPY package.json ./

RUN npm install

COPY . .

EXPOSE 1337
CMD ["npm", "run", "develop"]
