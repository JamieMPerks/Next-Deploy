FROM node:18-bullseye

WORKDIR /srv/app

# Copy only package.json
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest
COPY . .

EXPOSE 1337
CMD ["npm", "run", "develop"]
