# OCaml Game Geek

This project is based on the wonderful Lacinia GraphQL tutorial for Clojure. You can read more about it at [http://lacinia.readthedocs.io/en/latest/tutorial/](http://lacinia.readthedocs.io/en/latest/tutorial/).

This project makes use of
[Dream](https://github.com/aantron/dream)
and [ocmal-graphql-server](https://github.com/andreas/ocaml-graphql-server). Two awesome projects that I highly recommend you check out.

OCaml Game Geek is centered around building a GraphQL server that mimics some of the functionality of [Board Game Geek](https://boardgamegeek.com/).

## How to run

> npm install esy && npx esy

> npx esy start


#### Or if you prefer Docker

> docker build . -t ogg

> sudo docker run -t -i -p 8080:8080 --rm ogg

You should be able to now go to http://localhost:8080 in your web browser and play around with the schema.