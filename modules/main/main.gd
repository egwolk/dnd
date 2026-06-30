class_name main extends Node

func _ready() -> void:
	SceneManager.current_scene_container = $current_scene
	SceneManager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")