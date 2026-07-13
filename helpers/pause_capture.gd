class_name PauseCapture

var owner_state: LimboState
var map_state: LimboState

func _init(state: LimboState, map: LimboState) -> void:
	owner_state = state
	map_state = map

func frozen_bg() -> void:
	var img = owner_state.get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	Events.pause_background_captured.emit(tex)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		frozen_bg()
		owner_state.dispatch(&"PAUSE")
	if Input.is_action_just_pressed("m_pressed"):
		frozen_bg()
		map_state.can_dismiss = true
		owner_state.dispatch(&"MAP_SELECTED")


