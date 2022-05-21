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

type member = {
  member_id : int;
  member_name : string;
  ratings : game_rating list option;
}

type rating_map = {
  rm_member_id : int;
  rm_game_id : int;
  mutable rm_rating : int;
}
