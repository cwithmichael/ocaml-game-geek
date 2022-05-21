open Schema

let default_query =
  "{\\n  game(id: 1237) {\\n    name\\n    rating_summary {\\n    count\\n \
   average\\n } \\n  }\\n}\\n"

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger @@ Dream.origin_referrer_check
  @@ Dream.router
       [
         Dream.any "/graphql" (Dream.graphql Lwt.return ogg_schema);
         Dream.get "/" (Dream.graphiql ~default_query "/graphql");
       ]
