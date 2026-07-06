class_name map_view_state extends LimboState

@onready var map_ui = $map_screen

func _setup() -> void:
    map_ui.visible = false

func _enter() -> void:
    map_ui.visible = true

func _exit() -> void:
    map_ui.visible = false

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("m_pressed"):
        dispatch(&"RESUME_GAME")