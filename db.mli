open Ogg_types

val rating_maps_by_member_id : int -> rating_map list

val rating_maps_by_game_id : int -> rating_map list

val game_ratings_of_rating_maps : rating_map list -> game_rating option list

val get_all_games : (string * board_game) Seq.t

val get_all_designers : (string * designer) Seq.t

val get_all_members : (string * member) Seq.t

val get_all_ratings : (string * rating_map) Seq.t

val get_game_by_id : string -> board_game option

val get_member_by_id : string -> member option

val upsert_game_rating : int -> int -> int -> unit
