class_name start_menu_controller extends LimboHSM

@onready var root_node = $"."

@onready var start_state = $start_menu_state
@onready var extras_state = $extras_menu_state
@onready var config_state = $config_menu_state

func _ready() -> void:
    add_transition( start_state, extras_state, &"EXTRAS_SELECTED" )
    add_transition( start_state, config_state, &"CONFIG_SELECTED" )
    add_transition( ANYSTATE, start_state, &"CANCELLED")
    initialize(root_node)
    set_active(true)

func _update(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        dispatch( &"CANCELLED" )