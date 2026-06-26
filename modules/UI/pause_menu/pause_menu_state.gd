class_name pause_menu_state extends LimboState

@onready var pause_ui = $pause_menu

func _setup() -> void:
	pause_ui.visible = false

func _enter() -> void:
	pause_ui.visible = true

func _exit() -> void:
	pause_ui.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		dispatch(&"UNPAUSE")
