class_name game_view_controller extends LimboHSM

@onready var root_node = $"."

@onready var game_state = $game_view_state
@onready var pause_state = $pause_controller

func _ready() -> void:
    add_transition( game_state, pause_state, &"PAUSE_GAME" )
    add_transition( ANYSTATE, game_state, &"RESUME_GAME" )
    initialize(root_node)
    set_active(true)