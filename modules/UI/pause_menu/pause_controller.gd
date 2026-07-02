class_name pause_controller extends LimboHSM

@onready var pause_state = $pause_menu_state
@onready var extras_state = $extras_menu_state
@onready var config_state = $config_menu_state

func _ready() -> void:
	add_transition( pause_state, extras_state, &"EXTRAS_SELECTED" )
	add_transition( pause_state, config_state, &"CONFIG_SELECTED" )
	add_transition( ANYSTATE, pause_state, &"CANCELLED")

func _enter() -> void:
	get_tree().paused = true

func _exit() -> void:
	if is_inside_tree():
		get_tree().paused =  false
		

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		dispatch( &"CANCELLED" )
