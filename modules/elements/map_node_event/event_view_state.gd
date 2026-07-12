class_name event_view_state extends  map_base_node_view_state

func _get_ui_node() -> Control:
	return $event_view

func _on_next_node_pressed() -> void:
	map_state.can_dismiss = false
	dispatch(&"MAP_SELECTED")