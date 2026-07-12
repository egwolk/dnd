class_name map_base_node_view_state extends LimboState

@onready var map_state = %map_view_state

var ui_node: Control

func _setup() -> void:
	ui_node = _get_ui_node()
	ui_node.visible = false

func _enter() -> void:
	ui_node.visible = true

func _exit() -> void:
	ui_node.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		frozen_bg()
		dispatch(&"PAUSE")
	if Input.is_action_just_pressed("m_pressed"):
		frozen_bg()
		map_state.can_dismiss = true
		dispatch(&"MAP_SELECTED")

func frozen_bg() -> void:
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	Events.pause_background_captured.emit(tex)

func _get_ui_node() -> Control:
	push_error("base_room_view_state: _get_ui_node() not overridden")
	return null
