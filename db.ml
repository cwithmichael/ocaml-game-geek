open Ogg_types

let hardcoded_members = Hashtbl.create 10

let hardcoded_games = Hashtbl.create 10

let hardcoded_designers = Hashtbl.create 10

let hardcoded_ratings = Hashtbl.create 10

let get_all_games = Hashtbl.to_seq hardcoded_games

let get_all_members = Hashtbl.to_seq hardcoded_members

let get_all_designers = Hashtbl.to_seq hardcoded_designers

let get_game_by_id game_id = Hashtbl.find_opt hardcoded_games game_id

let get_member_by_id member_id = Hashtbl.find_opt hardcoded_members member_id

let rating_maps_by_member_id member_id =
  Hashtbl.fold
    (fun _ v acc -> if v.rm_member_id = member_id then v :: acc else acc)
    hardcoded_ratings []

let rating_maps_by_game_id game_id =
  Hashtbl.fold
    (fun _ v acc -> if v.rm_game_id = game_id then v :: acc else acc)
    hardcoded_ratings []

let game_ratings_of_rating_maps = function
  | [] -> []
  | xs ->
      List.map
        (fun rm ->
          match Hashtbl.find_opt hardcoded_games rm.rm_game_id with
          | None -> None
          | Some game -> Some { game; rating = rm.rm_rating })
        xs

let upsert_game_rating game_id member_id rating =
  let new_rating =
    { rm_rating = rating; rm_member_id = member_id; rm_game_id = game_id }
  in
  Hashtbl.replace hardcoded_ratings (member_id, game_id) new_rating

let () =
  Hashtbl.add hardcoded_members 37
    { member_id = 37; member_name = "curiousattemptbunny"; ratings = None };
  Hashtbl.add hardcoded_members 1410
    { member_id = 1410; member_name = "bleedingedge"; ratings = None };
  Hashtbl.add hardcoded_members 2812
    { member_id = 2812; member_name = "missyo"; ratings = None };

  Hashtbl.add hardcoded_designers 200
    {
      designer_id = 200;
      designer_name = "Kris Burm";
      url = Some "http://www.gipf.com/project_gipf/burm/burm.html";
      games = [];
    };
  Hashtbl.add hardcoded_designers 201
    {
      designer_id = 201;
      designer_name = "Antoine Bauza";
      url = Some "http://www.antoinebauza.fr/";
      games = [];
    };
  Hashtbl.add hardcoded_designers 202
    {
      designer_id = 202;
      designer_name = "Bruno Cathala";
      url = Some "http://www.bruno.com/";
      games = [];
    };
  Hashtbl.add hardcoded_designers 203
    { designer_id = 203; designer_name = "Scott Almes"; url = None; games = [] };
  Hashtbl.add hardcoded_designers 204
    {
      designer_id = 204;
      designer_name = "Donald X. Vaccarino";
      url = None;
      games = [];
    };
  Hashtbl.add hardcoded_games 1234
    {
      id = 1234;
      name = "Zertz";
      rating_summary = None;
      summary = Some "Two player abstract with forced moves and shrinking board";
      description = None;
      min_players = Some 2;
      max_players = Some 2;
      play_time = None;
      designers = [ Hashtbl.find hardcoded_designers 200 ];
    };
  Hashtbl.add hardcoded_games 1235
    {
      id = 1235;
      name = "Dominion";
      rating_summary = None;
      summary = Some "Created the deck-building genre; zillions of expansions";
      description = None;
      min_players = Some 2;
      max_players = None;
      play_time = None;
      designers = [ Hashtbl.find hardcoded_designers 204 ];
    };
  Hashtbl.add hardcoded_games 1236
    {
      id = 1236;
      name = "Tiny Epic Galaxies";
      rating_summary = None;
      summary = Some "Fast dice-based sci-fi space game with a bit of chaos";
      description = None;
      min_players = Some 1;
      max_players = Some 4;
      play_time = None;
      designers = [ Hashtbl.find hardcoded_designers 203 ];
    };
  Hashtbl.add hardcoded_games 1237
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
          Hashtbl.find hardcoded_designers 201;
          Hashtbl.find hardcoded_designers 202;
        ];
    };

  Hashtbl.add hardcoded_ratings (37, 1234)
    { rm_member_id = 37; rm_game_id = 1234; rm_rating = 3 };
  Hashtbl.add hardcoded_ratings (1410, 1234)
    { rm_member_id = 1410; rm_game_id = 1234; rm_rating = 5 };
  Hashtbl.add hardcoded_ratings (1410, 1236)
    { rm_member_id = 1410; rm_game_id = 1236; rm_rating = 4 };
  Hashtbl.add hardcoded_ratings (1410, 1237)
    { rm_member_id = 1410; rm_game_id = 1237; rm_rating = 4 };
  Hashtbl.add hardcoded_ratings (2812, 1237)
    { rm_member_id = 2812; rm_game_id = 1237; rm_rating = 4 };
  Hashtbl.add hardcoded_ratings (37, 1237)
    { rm_member_id = 37; rm_game_id = 1237; rm_rating = 5 }
