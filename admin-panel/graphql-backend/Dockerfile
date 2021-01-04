FROM node:12

# Create app directory
WORKDIR /graphql

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

# TODO, we should skip the node_modules folder ...
COPY . .

EXPOSE 4000
CMD [ "npm", "run", "start" ]