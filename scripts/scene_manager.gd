extends Node

var current_scene_container: Node
var current_scene_instance: Node

func goto_scene(path: String) -> void:
	if current_scene_instance:
		current_scene_instance.queue_free()
	var new_scene = load(path).instantiate()
	current_scene_container.add_child(new_scene)
	current_scene_instance = new_scene