FROM node:16-bullseye AS base
RUN apt-get update
RUN apt-get -y install openssl libssl-dev

FROM base AS build
WORKDIR /build
RUN npm install esy
COPY esy.json .
RUN npx esy
COPY . .
EXPOSE 8080
CMD [ "npx", "esy", "start" ]