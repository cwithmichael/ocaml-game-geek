FROM node:16-bullseye AS base
WORKDIR /app
RUN apt-get update 
RUN apt-get -y install openssl libssl-dev

FROM base AS build
COPY . .
RUN npm install esy 
RUN npx esy

FROM build AS run
EXPOSE 8080
CMD ["npx", "esy", "start"]
