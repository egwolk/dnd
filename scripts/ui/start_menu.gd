extends Control


func _ready():
    %new_game.pressed.connect(newGame)
    %extras.pressed.connect(extras)

func newGame():
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func extras():
    get_tree().change_scene_to_file("res://scenes/ui/extras_screen.tscn")


