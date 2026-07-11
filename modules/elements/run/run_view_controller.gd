class_name run_view_controller extends LimboHSM

@onready var root_node = $"."

@onready var pause_state = $pause_controller

@onready var lose_state = $lose_view_state
@onready var win_state = $win_view_state

@onready var map_state = $map_view_state

@onready var fishing_state = $fishing_view_state
@onready var shop_state = $shop_view_state
@onready var event_state = $event_view_state
@onready var boss_state = $boss_view_state

func _ready() -> void:
	add_transition( ANYSTATE, pause_state, &"PAUSE" )
	add_event_handler( &"UNPAUSE", _on_unpause )
	add_transition( ANYSTATE, win_state, &"WIN_SELECTED" )

	add_transition( win_state, fishing_state, &"CONTINUE_SELECTED" )
	
	add_transition( ANYSTATE, lose_state, &"LOSE_SELECTED" )

	add_transition( ANYSTATE, map_state, &"MAP_SELECTED" )

	add_transition( map_state, fishing_state, &"FISHING_SELECTED" )
	add_transition( map_state, shop_state, &"SHOP_SELECTED" )
	add_transition( map_state, event_state, &"EVENT_SELECTED" )
	add_transition( map_state, boss_state, &"BOSS_SELECTED" )

	initialize(root_node)
	set_active(true)


func _on_unpause() -> bool:
	change_active_state(get_previous_active_state())
	return true
