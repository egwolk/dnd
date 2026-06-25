class_name start_menu extends Control


func _ready() -> void:
	%new_game.pressed.connect(newGame)
	%quit.pressed.connect(quit)

func newGame() -> void:
	scene_manager.goto_scene("res://modules/elements/game/game.tscn")

func quit() -> void:
	get_tree().quit()
