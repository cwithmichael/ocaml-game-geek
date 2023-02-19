FROM ocaml/opam:alpine-ocaml-4.10 as build

# Install system dependencies
RUN sudo apk add --update libev-dev openssl-dev

WORKDIR /home/opam

# Install dependencies
COPY ogg.opam ogg.opam
RUN opam install . --deps-only

# Build project
COPY . .
RUN opam exec -- dune build



FROM alpine as run

RUN apk add --update libev
COPY --from=build /home/opam/_build/default/ogg_server.exe /bin/ogg_server
EXPOSE 8080
ENTRYPOINT ["/bin/ogg_server"]
