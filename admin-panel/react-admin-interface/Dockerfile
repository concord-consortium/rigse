FROM node:12

# Create app directory
WORKDIR /admin-interface

# TODO, we should skip the node_modules folder ...
COPY . .

# Install app dependencies
COPY package.json ./

RUN npm install
# If you are building your code for production
# RUN npm ci --only=production

EXPOSE 3000
CMD [ "npm", "run", "start" ]