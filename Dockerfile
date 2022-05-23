FROM node:16-bullseye-slim AS base
RUN apt-get update && apt-get install -y libssl-dev curl git xz-utils \
    lbzip2 gcc make

FROM base AS build
WORKDIR /build
RUN npm install esy
COPY esy.json .
RUN npx esy solve
RUN npx esy fetch
RUN npx esy build-dependencies

COPY . .
RUN npx esy build
EXPOSE 8080
CMD ["npx", "esy", "start"]