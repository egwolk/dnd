class_name start_menu_state extends LimboState

@onready var start_ui = $start_menu

func _setup() -> void:
	start_ui.visible = false

func _enter() -> void:
	start_ui.visible = true

func _exit() -> void:
	start_ui.visible = false



func _on_new_game_pressed() -> void:
	SceneManager.goto_scene("res://modules/UI/game_view/game_view.tscn")
