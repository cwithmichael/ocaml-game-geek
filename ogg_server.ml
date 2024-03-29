open Db
open Ogg_types

let rating_average = function
  | [] -> None
  | ratings ->
      let n = List.length ratings in
      Some
        {
          count = n;
          average =
            List.fold_left
              (fun acc rm -> acc +. float_of_int rm.rm_rating)
              0.0 ratings
            /. float_of_int n;
        }

exception InvalidId of string
exception InvalidRating of string

let rate_game game_id member_id rating =
  if rating >= 1 && rating <= 5 then
    let game = get_game_by_id game_id in
    let member = get_member_by_id member_id in
    match (game, member) with
    | Some _, Some _ ->
        upsert_game_rating game_id member_id rating;
        game
    | _ -> raise @@ InvalidId "Invalid game_id or member_id"
  else raise @@ InvalidRating "Invalid Rating"

let game_rating_summary =
  Graphql_lwt.Schema.(
    obj "game_rating_summary" ~doc:"Summary of ratings for a single game."
      ~fields:
        [
          field "count"
            ~doc:
              "Number of ratings provided for the game.  Ratings are 1 to 5 \
               stars."
            ~typ:(non_null int)
            ~args:Arg.[]
            ~resolve:(fun _ game_rating_summary -> game_rating_summary.count);
          field "average"
            ~doc:"The average value of all ratings, or 0 if never rated."
            ~typ:(non_null float)
            ~args:Arg.[]
            ~resolve:(fun _ game_rating_summary -> game_rating_summary.average);
        ])

let designer, board_game =
  Graphql_lwt.Schema.(
    fix (fun recursive ->
        let designer =
          recursive.obj "designer"
            ~doc:"A person who may have contributed to a board game design."
            ~fields:(fun (_, board_game) ->
              [
                field "designer_id" ~typ:(non_null int)
                  ~args:Arg.[]
                  ~resolve:(fun _ designer -> designer.designer_id);
                field "designer_name" ~typ:(non_null string)
                  ~args:Arg.[]
                  ~resolve:(fun _ designer -> designer.designer_name);
                field "url" ~doc:"Home page URL, if known." ~typ:string
                  ~args:Arg.[]
                  ~resolve:(fun _ designer -> designer.url);
                field "games" ~doc:"Games designed by this designer."
                  ~typ:(non_null (list (non_null board_game)))
                  ~args:Arg.[]
                  ~resolve:(fun _ designer -> designer.games);
              ])
        in
        let board_game =
          recursive.obj "board_game" ~doc:"A physical or virtual board game."
            ~fields:(fun (designer, _) ->
              [
                field "id" ~typ:(non_null int)
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.id);
                field "name" ~typ:(non_null string)
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.name);
                field "rating_summary" ~typ:game_rating_summary
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game ->
                    rating_maps_by_game_id board_game.id |> rating_average);
                field "summary" ~doc:"A one-line summary of the game."
                  ~typ:string
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.summary);
                field "description" ~doc:"A long-form description of the game."
                  ~typ:string
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.description);
                field "designers" ~doc:"Designers who contributed to the game."
                  ~typ:(non_null (list (non_null designer)))
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.designers);
                field "min_players"
                  ~doc:"The minimum number of players the game supports."
                  ~typ:int
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.min_players);
                field "max_players"
                  ~doc:"The maximum number of players the game supports."
                  ~typ:int
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.max_players);
                field "play_time"
                  ~doc:"Play time, in minutes, for a typical game." ~typ:int
                  ~args:Arg.[]
                  ~resolve:(fun _ board_game -> board_game.play_time);
              ])
        in
        (designer, board_game)))

let game_rating =
  Graphql_lwt.Schema.(
    obj "game_rating" ~doc:"A member's rating of a particular game."
      ~fields:
        [
          field "game" ~doc:"The Game rated by the member."
            ~typ:(non_null board_game)
            ~args:Arg.[]
            ~resolve:(fun _ game_rating -> game_rating.game);
          field "rating" ~doc:"The rating as 1 to 5 stars." ~typ:(non_null int)
            ~args:Arg.[]
            ~resolve:(fun _ game_rating -> game_rating.rating);
        ])

let member =
  Graphql_lwt.Schema.(
    obj "member" ~doc:"A member of OCaml Game Geek.  Members can rate games."
      ~fields:
        [
          field "member_id" ~typ:(non_null int)
            ~args:Arg.[]
            ~resolve:(fun _ member -> member.member_id);
          field "member_name" ~doc:"Unique name of member."
            ~typ:(non_null string)
            ~args:Arg.[]
            ~resolve:(fun _ member -> member.member_name);
          field "ratings"
            ~doc:"List of games and ratings provided by this member."
            ~typ:(list game_rating)
            ~args:Arg.[]
            ~resolve:(fun _ member ->
              match
                game_ratings_of_rating_maps
                @@ rating_maps_by_member_id member.member_id
              with
              | [] -> Some []
              | ratings -> Some ratings);
        ])

let ogg_schema =
  Graphql_lwt.Schema.(
    schema ~query_name:"OCamlGameGeekQuery"
      [
        field "game" ~doc:"Select a BoardGame by its unique id, if it exists."
          ~typ:board_game
          ~args:Arg.[ arg "id" ~typ:int ]
          ~resolve:(fun _ () id ->
            match id with None -> None | Some id' -> get_game_by_id id');
        field "member"
          ~doc:
            "Select an OCaml Game Geek Member by their unique id, if it exists."
          ~typ:member
          ~args:Arg.[ arg "id" ~typ:int ]
          ~resolve:(fun _ () member_id ->
            match member_id with
            | None -> None
            | Some member_id' -> get_member_by_id member_id');
        field "games" ~doc:"Get all BoardGames"
          ~typ:(non_null (list board_game))
          ~args:Arg.[]
          ~resolve:(fun _ () ->
            Seq.fold_left (fun acc x -> Some (snd x) :: acc) [] get_all_games);
        field "members" ~doc:"Get all members"
          ~typ:(non_null (list member))
          ~args:Arg.[]
          ~resolve:(fun _ () ->
            Seq.fold_left (fun acc x -> Some (snd x) :: acc) [] get_all_members);
        field "designers" ~doc:"Get all designers"
          ~typ:(non_null (list designer))
          ~args:Arg.[]
          ~resolve:(fun _ () ->
            Seq.fold_left
              (fun acc x -> Some (snd x) :: acc)
              [] get_all_designers);
      ]
      ~mutation_name:"OCamlGameGeekMutation"
      ~mutations:
        [
          field "rate_game"
            ~doc:
              "Establishes a rating of a board game, by a Member. On success \
               (the game and member both exist), selects the BoardGame."
            ~typ:board_game
            ~args:
              Arg.
                [
                  arg "game_id" ~typ:(non_null int);
                  arg "member_id" ~typ:(non_null int);
                  arg "rating" ~typ:(non_null int);
                ]
            ~resolve:(fun _ () game_id member_id rating ->
              rate_game game_id member_id rating);
          field "add_member" ~doc:"Adds a new Member." ~typ:(non_null member)
            ~args:Arg.[ arg "member_name" ~typ:(non_null string) ]
            ~resolve:(fun _ () member_name -> add_member member_name);
        ])

let default_query =
  "{\\n  game(id: 1237) {\\n    name\\n    rating_summary {\\n    count\\n \
   average\\n } \\n  }\\n}\\n"

let mutation_error_template (_error : Dream.error) _ suggested_response =
  let status = Dream.status suggested_response in
  let reason =
    match _error.condition with
    | `Exn e -> (
        match e with
        | InvalidId s | InvalidRating s ->
            Dream.set_status suggested_response `Bad_Request;
            s
        | _ -> "Unknown Error")
    | _ -> Dream.status_to_string status
  in
  Dream.set_header suggested_response "Content-Type" Dream.application_json;
  Dream.set_body suggested_response
  @@ Printf.sprintf "{\"errors\" : [{\"message\" : \"%s\"}]}" reason;
  Lwt.return suggested_response

let () =
  Dream.run ~interface:"0.0.0.0"
    ~error_handler:(Dream.error_template mutation_error_template)
  @@ Dream.logger @@ Dream.origin_referrer_check
  @@ Dream.router
       [
         Dream.any "/graphql" (Dream.graphql Lwt.return ogg_schema);
         Dream.get "/" (Dream.graphiql ~default_query "/graphql");
       ]
