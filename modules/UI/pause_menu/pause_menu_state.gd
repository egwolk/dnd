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
	get_tree().paused = false
	SceneManager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")
