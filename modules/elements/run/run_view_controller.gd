class_name run_view_controller extends LimboHSM

@onready var root_node = $"."

@onready var game_state = $game_view_state
@onready var pause_state = $pause_controller
@onready var lose_state = $lose_view_state
@onready var win_state = $win_view_state
@onready var map_state = $map_view_state

func _ready() -> void:
	add_transition( ANYSTATE, pause_state, &"PAUSE" )
	add_transition( game_state, win_state, &"WIN_SELECTED" )
	add_transition( win_state, game_state, &"CONTINUE_SELECTED" )
	add_transition( game_state, lose_state, &"LOSE_SELECTED" )
	add_transition( map_state, game_state, &"LEVEL_SELECTED" )
	add_transition( game_state, map_state, &"MAP_SELECTED" )
	add_event_handler( &"UNPAUSE", _on_unpause )
	initialize(root_node)
	set_active(true)


func _on_unpause() -> bool:
	change_active_state(get_previous_active_state())
	return true