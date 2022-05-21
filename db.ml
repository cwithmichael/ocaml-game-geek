open Types

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
  | xs ->(
      Some
        (List.map
           (fun rm ->
             {
               game =
                 List.find (fun gm -> rm.rm_game_id = gm.id) hardcoded_games;
               rating = rm.rm_rating;
             })
           xs))

let get_all_games = hardcoded_games
let get_all_members = hardcoded_members
let get_all_designers = hardcoded_designers
let get_all_ratings =  hardcoded_ratings
