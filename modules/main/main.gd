class_name main extends Node

func _ready() -> void:
	scene_manager.current_scene_container = $current_scene
	scene_manager.ui_layer = $ui_layer
	scene_manager.goto_scene("res://modules/UI/start_menu/start_menu.tscn")
