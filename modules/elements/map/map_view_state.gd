class_name map_view_state extends LimboState

@onready var map_ui = $map

var can_dismiss: bool = false:
	set(value):
		can_dismiss = value
		_set_buttons_disabled(value)


func _setup() -> void:
	map_ui.visible = false
	Events.selected.connect(_on_node_selected)
	map_ui.generate_new_map()
	map_ui.unlock_node(0)

func _enter() -> void:
	map_ui.visible = true
	map_ui.scroll_to_current_node()
	Events.can_dismiss_changed.emit(can_dismiss)
	get_tree().paused = true

func _exit() -> void:
	map_ui.visible = false

func _set_buttons_disabled(value: bool) -> void:
	for button in get_tree().get_nodes_in_group("map_buttons"):
		button.disabled = value

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if can_dismiss:
			get_tree().paused = false
			Events.pause_background_cleared.emit()
			dispatch(&"UNPAUSE")
		else:
			dispatch(&"PAUSE")
	elif Input.is_action_just_pressed("m_pressed"):
		if can_dismiss:
			get_tree().paused = false
			Events.pause_background_cleared.emit()
			dispatch(&"UNPAUSE")
		else:
			return

func _on_node_selected(step: MapNode) -> void:
	can_dismiss = true
	get_tree().paused = false
	Events.map_node_pressed.emit()
	Events.pause_background_cleared.emit()
	match step.type:
		MapNode.Type.FISHING:
			dispatch(&"FISHING_SELECTED")
		MapNode.Type.BOSS:
			dispatch(&"BOSS_SELECTED")
		MapNode.Type.EVENT:
			dispatch(&"EVENT_SELECTED")
		MapNode.Type.SHOP:
			dispatch(&"SHOP_SELECTED")
