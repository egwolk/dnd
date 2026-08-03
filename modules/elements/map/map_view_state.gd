class_name map_view_state extends LimboState

@onready var map_ui = $map

const INTRO_SCROLL_DELAY := 0.6

var is_first_visit := true
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
	Events.can_dismiss_changed.emit(can_dismiss)
	get_tree().paused = true
	WaterOverlayManager.show_in(map_ui)
	await get_tree().process_frame

	if is_first_visit:
		is_first_visit = false
		map_ui.visible = true
		_set_buttons_disabled(true)
		map_ui.lock_scroll()
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().create_timer(INTRO_SCROLL_DELAY).timeout
		await map_ui.play_intro_scroll(can_dismiss)
		_set_buttons_disabled(can_dismiss)
	else:
		map_ui.scroll_to_current_node(can_dismiss)
		map_ui.visible = true
		
func _exit() -> void:
	map_ui.visible = false
	WaterOverlayManager.hide_overlay()

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
