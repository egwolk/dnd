class_name win_view_state 
extends LimboState

@onready var win_ui = $win_screen

func _setup() -> void:
	win_ui.visible = false

func _enter() -> void:
	win_ui.visible = true
	get_tree().paused = true

func _exit() -> void:
	win_ui.visible = false


func _on_quit_pressed() -> void:
	get_tree().paused = false
	Events.pause_background_cleared.emit()
	SceneManager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")


func _on_continue_pressed() -> void:
	get_tree().paused = false
	Events.pause_background_cleared.emit()
	dispatch(&"RESUME_GAME")
