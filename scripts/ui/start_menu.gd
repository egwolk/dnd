extends Control


func _ready():
    %new_game.pressed.connect(play)

func play():
    get_tree().change_scene_to_file("res://scenes/main.tscn")