class_name start_menu_state extends LimboState

@onready var start_ui = $start_menu

func _setup() -> void:
    start_ui.visible = false

func _enter() -> void:
    start_ui.visible = true

func _exit() -> void:
    start_ui.visible = false


