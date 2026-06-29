class_name pause_menu_state extends LimboState

@onready var pause_ui = $pause_menu

func _setup() -> void:
	pause_ui.visible = false

func _enter() -> void:
	pause_ui.visible = true

func _exit() -> void:
	pause_ui.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		dispatch(&"RESUME_GAME")

func _on_quit_pressed() -> void:
	Events.quit_to_main_requested.emit()
	dispatch( &"QUIT_TO_MAIN" )
