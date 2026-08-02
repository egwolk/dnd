extends Node

var current_scene_container: Node
var current_scene_instance: Node

const DEFAULT_LOADING_SCREEN := "res://modules/UI/loading_screen/loading_screen.tscn"

func goto_scene(path: String) -> void:
	if current_scene_instance:
		WaterOverlayManager.reclaim()
		current_scene_instance.queue_free()
	var new_scene = load(path).instantiate()
	current_scene_container.add_child(new_scene)
	current_scene_instance = new_scene

func goto_scene_async(path: String, loading_screen_path: String = DEFAULT_LOADING_SCREEN) -> void:
	if current_scene_instance:
		WaterOverlayManager.reclaim()
		current_scene_instance.queue_free()
	var loading_screen = load(loading_screen_path).instantiate()
	current_scene_container.add_child(loading_screen)
	current_scene_instance = loading_screen
	loading_screen.begin_load(path)