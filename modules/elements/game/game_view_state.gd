class_name game_view_state extends LimboState

@onready var game_view = $game_root

func _setup() -> void:
    game_view.visible = false

func _enter() -> void:
    game_view.visible = true

func _exit() -> void:
    game_view.visible = false

func  _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        dispatch( &"PAUSE_GAME" )