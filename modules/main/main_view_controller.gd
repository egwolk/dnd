class_name main_view_controller extends LimboHSM

@onready var root_node = $"."

@onready var start_state = $start_menu_controller
@onready var game_state = $game_view_state
@onready var pause_state = $pause_controller

func _ready() -> void:
    add_transition( start_state, game_state, &"GAMEPLAY" )
    add_transition( game_state, pause_state, &"PAUSE_GAME")
    add_transition( pause_state, game_state, &"RESUME_GAME")
    add_transition( pause_state, start_state, &"QUIT_TO_MAIN")

    get_tree().paused = false
    initialize(root_node)
    set_active(true)