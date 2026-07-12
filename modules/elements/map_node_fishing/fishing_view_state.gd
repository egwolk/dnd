class_name fishing_view_state extends map_base_node_view_state

func _get_ui_node() -> Control:
	return $fishing_view

func _on_lose_test_pressed() -> void:
	frozen_bg()
	dispatch(&"LOSE_SELECTED")

func _on_win_test_pressed() -> void:
	frozen_bg()
	dispatch(&"WIN_SELECTED")