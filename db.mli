open Types

val rating_maps_by_member_id : int -> rating_map list
val rating_maps_by_game_id :  int -> rating_map list
val game_ratings_of_rating_maps : rating_map list -> game_rating list option
val get_all_games :  board_game list
val get_all_designers :  (string * Types.designer) list
val get_all_members : (string * Types.member) list
val get_all_ratings : rating_map list
