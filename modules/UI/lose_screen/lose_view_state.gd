class_name lose_view_state extends LimboState

@onready var lose_ui = $lose_screen

func _setup() -> void:
	lose_ui.visible = false

func _enter() -> void:
	get_tree().paused = true
	lose_ui.visible = true

func _exit() -> void:
	lose_ui.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	SceneManager.goto_scene(SceneManager.current_scene_instance.scene_file_path)

func _on_quit_pressed() -> void:
	get_tree().paused = false
	SceneManager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")
