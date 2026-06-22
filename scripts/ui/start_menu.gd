extends Control


func _ready() -> void:
	%new_game.pressed.connect(newGame)
	%quit.pressed.connect(quit)

func newGame() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func quit() -> void:
	get_tree().quit()
