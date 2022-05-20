type game_rating_summary = { count : int; average : float }

type designer = {
  designer_id : int;
  designer_name : string;
  url : string option;
  games : board_game list;
}

and board_game = {
  id : int;
  name : string;
  rating_summary : game_rating_summary option;
  summary : string option;
  description : string option;
  min_players : int option;
  max_players : int option;
  play_time : int option;
  designers : designer list;
}

type game_rating = { game : board_game; rating : int }

and member = {
  member_id : int;
  member_name : string;
  ratings : game_rating list option;
}

type rating_map = { rm_member_id : int; rm_game_id : int; rm_rating : int }

let hardcoded_members =
  [
    ( "37",
      { member_id = 37; member_name = "curiousattemptbunny"; ratings = None } );
    ("1410", { member_id = 1410; member_name = "bleedingedge"; ratings = None });
    ("2812", { member_id = 2812; member_name = "missyo"; ratings = None });
  ]

let hardcoded_designers =
  [
    ( "200",
      {
        designer_id = 200;
        designer_name = "Kris Burm";
        url = Some "http://www.gipf.com/project_gipf/burm/burm.html";
        games = [];
      } );
    ( "201",
      {
        designer_id = 201;
        designer_name = "Antoine Bauza";
        url = Some "http://www.antoinebauza.fr/";
        games = [];
      } );
    ( "202",
      {
        designer_id = 202;
        designer_name = "Bruno Cathala";
        url = Some "http://www.bruno.com/";
        games = [];
      } );
    ( "203",
      {
        designer_id = 203;
        designer_name = "Scott Almes";
        url = None;
        games = [];
      } );
    ( "204",
      {
        designer_id = 204;
        designer_name = "Donald X. Vaccarino";
        url = None;
        games = [];
      } );
  ]

let hardcoded_games =
  [
    {
      id = 1234;
      name = "Zertz";
      rating_summary = None;
      summary = Some "Two player abstract with forced moves and shrinking board";
      description = None;
      min_players = Some 2;
      max_players = Some 2;
      play_time = None;
      designers = [ List.assoc "200" hardcoded_designers ];
    };
    {
      id = 1235;
      name = "Dominion";
      rating_summary = None;
      summary = Some "Created the deck-building genre; zillions of expansions";
      description = None;
      min_players = Some 2;
      max_players = None;
      play_time = None;
      designers = [ List.assoc "204" hardcoded_designers ];
    };
    {
      id = 1236;
      name = "Tiny Epic Galaxies";
      rating_summary = None;
      summary = Some "Fast dice-based sci-fi space game with a bit of chaos";
      description = None;
      min_players = Some 1;
      max_players = Some 4;
      play_time = None;
      designers = [ List.assoc "203" hardcoded_designers ];
    };
    {
      id = 1237;
      name = "7 Wonders: Duel";
      rating_summary = None;
      summary = Some "Tense, quick card game of developing civilizations";
      description = None;
      min_players = Some 2;
      max_players = Some 2;
      play_time = None;
      designers =
        [
          List.assoc "201" hardcoded_designers;
          List.assoc "202" hardcoded_designers;
        ];
    };
  ]

let hardcoded_ratings =
  [
    { rm_member_id = 37; rm_game_id = 1234; rm_rating = 3 };
    { rm_member_id = 1410; rm_game_id = 1234; rm_rating = 5 };
    { rm_member_id = 1410; rm_game_id = 1236; rm_rating = 4 };
    { rm_member_id = 1410; rm_game_id = 1237; rm_rating = 4 };
    { rm_member_id = 2812; rm_game_id = 1237; rm_rating = 4 };
    { rm_member_id = 37; rm_game_id = 1237; rm_rating = 5 };
  ]

let rating_maps_by_member_id member_id =
  List.find_all (fun x -> x.rm_member_id = member_id) hardcoded_ratings

let rating_maps_by_game_id game_id =
  List.find_all (fun x -> x.rm_game_id = game_id) hardcoded_ratings

let game_ratings_of_rating_maps = function
  | [] -> None
  | xs ->
      Some
        (List.map
           (fun rm ->
             {
               game =
                 List.find (fun gm -> rm.rm_game_id = gm.id) hardcoded_games;
               rating = rm.rm_rating;
             })
           xs)

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

let game_rating_summary =
  Graphql_lwt.Schema.(
    obj "game_rating_summary" ~doc:"Summary of ratings for a single game."
      ~fields:(fun _ ->
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
        ]))

let rec board_game =
  lazy
    Graphql_lwt.Schema.(
      obj "board_game" ~doc:"A physical or virtual board game."
        ~fields:(fun _ ->
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
            field "summary" ~doc:"A one-line summary of the game." ~typ:string
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.summary);
            field "description" ~doc:"A long-form description of the game."
              ~typ:string
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.description);
            field "designers" ~doc:"Designers who contributed to the game."
              ~typ:(non_null (list (non_null Lazy.(force designer))))
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.designers);
            field "min_players"
              ~doc:"The minimum number of players the game supports." ~typ:int
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.min_players);
            field "max_players"
              ~doc:"The maximum number of players the game supports." ~typ:int
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.max_players);
            field "play_time" ~doc:"Play time, in minutes, for a typical game."
              ~typ:int
              ~args:Arg.[]
              ~resolve:(fun _ board_game -> board_game.play_time);
          ]))

and designer =
  lazy
    Graphql_lwt.Schema.(
      obj "designer"
        ~doc:"A person who may have contributed to a board game design."
        ~fields:(fun _ ->
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
              ~typ:(non_null (list (non_null Lazy.(force board_game))))
              ~args:Arg.[]
              ~resolve:(fun _ designer -> designer.games);
          ]))

let game_rating =
  Graphql_lwt.Schema.(
    obj "game_rating" ~doc:"A member's rating of a particular game."
      ~fields:(fun _ ->
        [
          field "game" ~doc:"The Game rated by the member."
            ~typ:(non_null Lazy.(force board_game))
            ~args:Arg.[]
            ~resolve:(fun _ game_rating -> game_rating.game);
          field "rating" ~doc:"The rating as 1 to 5 stars." ~typ:(non_null int)
            ~args:Arg.[]
            ~resolve:(fun _ game_rating -> game_rating.rating);
        ]))

let member =
  Graphql_lwt.Schema.(
    obj "member" ~doc:"A member of OCaml Game Geek.  Members can rate games."
      ~fields:(fun _ ->
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
            ~typ:(list (non_null game_rating))
            ~args:Arg.[]
            ~resolve:(fun _ member ->
              game_ratings_of_rating_maps
              @@ rating_maps_by_member_id member.member_id);
        ]))

let schema =
  Graphql_lwt.Schema.(
    schema
      [
        field "game" ~doc:"Select a BoardGame by its unique id, if it exists."
          ~typ:Lazy.(force board_game)
          ~args:Arg.[ arg "id" ~typ:int ]
          ~resolve:(fun _ () id ->
            match id with
            | None -> None
            | Some id' -> (
                match
                  List.find_opt (fun { id; _ } -> id = id') hardcoded_games
                with
                | None -> None
                | Some board_game -> Some board_game));
        field "member"
          ~doc:
            "Select an OCaml Game Geek Member by their unique id, if it exists."
          ~typ:member
          ~args:Arg.[ arg "id" ~typ:int ]
          ~resolve:(fun _ () member_id ->
            match member_id with
            | None -> None
            | Some member_id' -> (
                match
                  List.assoc_opt (string_of_int member_id') hardcoded_members
                with
                | None -> None
                | Some member -> Some member));
      ])

let default_query =
  "{\\n  game(id: 1237) {\\n    name\\n    rating_summary {\\n    count\\n \
   average\\n } \\n  }\\n}\\n"

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger @@ Dream.origin_referrer_check
  @@ Dream.router
       [
         Dream.any "/graphql" (Dream.graphql Lwt.return schema);
         Dream.get "/" (Dream.graphiql ~default_query "/graphql");
       ]
