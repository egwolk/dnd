extends Control


func _ready() -> void:
    %new_game.pressed.connect(newGame)
    %extras.pressed.connect(extras)
    %config.pressed.connect(config)
    %quit.pressed.connect(quit)

func newGame() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func extras() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/extras_screen.tscn")

func config() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/config_screen.tscn")

func quit() -> void:
    get_tree().quit()


