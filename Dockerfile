FROM node:12-alpine
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY src/. .
COPY src/package.json /usr/src/app/
RUN npm install -g npm@latest
RUN npm install ws
RUN npm install prom-client
RUN apk add --no-cache bash
RUN apk add curl
EXPOSE 80
CMD [ "node", "server.js" ]